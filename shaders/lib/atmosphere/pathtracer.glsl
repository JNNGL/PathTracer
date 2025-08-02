/*
 *  Copyright (C) 2025  JNNGL
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef _ATMOSPHERE_PATHTRACER_GLSL
#define _ATMOSPHERE_PATHTRACER_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/atmosphere/constants.glsl"
#include "/lib/atmosphere/density.glsl"
#include "/lib/atmosphere/scattering.glsl"
#include "/lib/atmosphere/sun.glsl"
#include "/lib/utility/intersectors.glsl"
#include "/lib/utility/random.glsl"

float estimateTransmittance(ray r, vec3 beta) {
    vec2 earthDist = intersectSphere(r, vec3(0.0), earthRadius);
    vec2 atmosphereDist = intersectSphere(r, vec3(0.0), atmosphereRadius);
    
    if (atmosphereDist.y < 0.0) {
        return 1.0;
    }
    if (earthDist.y >= 0.0) {
        return 0.0;
    }
    
    float t = max(0.0, atmosphereDist.x);
    r.origin += r.direction * t;
    
    vec3 betaMax = beta * maxAtmosphereDensity();
    float betaSum = betaMax.x + betaMax.y + betaMax.z;
    
    float transmittance = 1.0;
    while (t < atmosphereDist.y) {
        float flightDistance = -log(1.0 - random1()) / betaSum;
        
        r.origin += r.direction * flightDistance;
        t += flightDistance;
        
        float height = length(r.origin);
        
        vec3 betaH = beta * atmosphereDensity(height) / betaSum;
        transmittance *= 1.0 - betaH.x - betaH.y - betaH.z;
    }
    
    return transmittance;
}

vec2 compositeDeltaTracking(ray r, vec3 beta) {
    vec2 atmosphereDist = intersectSphere(r, vec3(0.0), atmosphereRadius);
    if (atmosphereDist.y < 0.0) {
        return vec2(-1.0);
    }
    
    float t = max(0.0, atmosphereDist.x);
    r.origin += r.direction * t;
    
    vec3 betaMax = beta * maxAtmosphereDensity();
    float betaSum = betaMax.x + betaMax.y + betaMax.z;
    
    for (int i = 0; i < 1024; i++) {
        float flightDistance = -log(1.0 - random1()) / betaSum;
        
        r.origin += r.direction * flightDistance;
        t += flightDistance;
        
        float height = length(r.origin);
        if (clamp(height, earthRadius, atmosphereRadius) != height) {
            return vec2(-1.0);
        }
        
        vec3 betaH = beta * atmosphereDensity(height) / betaSum;
        
        float r = random1();
        if (r >= betaH.x + betaH.y + betaH.z) {
            continue; // Null collision
        }
        
        float particle = 2.0;
        if (r < betaH.x) {
            particle = 0.0;
        } else if (r < betaH.x + betaH.y) {
            particle = 1.0;
        }
        
        return vec2(t, particle);
    }
    
    return vec2(-1.0);
}

float pathTraceAtmosphere(ray r, vec3 sunPosition, float sunRadiance, vec3 beta, float wavelength) {
    float L = 0.0;
    float throughput = 1.0;
    
    for (int i = 0; i < 64; i++) {
        vec2 interaction = compositeDeltaTracking(r, beta);
        if (interaction.x < 0.0) {
            break;
        }
        
        r.origin += r.direction * interaction.x;
        
        if ((interaction.y == 2.0) || // Ozone
            (interaction.y == 1.0 && random1() > (1.0 / 1.1))) { // Aerosols
            break; // Absorption
        }
        
        float weight;
        vec3 sunDirection = sampleSunDirection(random2(), sunPosition, r.origin, weight);
        
        float transmittance = estimateTransmittance(ray(r.origin, sunDirection), beta);
        
        vec3 wo;
        float phaseLight, estimator;
        if (interaction.y == 0.0) { // Air molecules
            phaseLight = rayleighPhase(dot(r.direction, sunDirection), wavelength);
            
            wo = sampleSphere(random2());
            estimator = 4.0 * PI * rayleighPhase(dot(r.direction, wo), wavelength);
        } else if (interaction.y == 1.0) { // Aerosols
            phaseLight = hgDrainePhase(dot(r.direction, sunDirection), aerosolDiameter);
            
            wo = sampleHgDraine(r.direction, random3(), aerosolDiameter);
            estimator = 1.0;
        }
        
        r.direction = wo;
        
        L += throughput * weight * transmittance * phaseLight * sunRadiance;
        throughput *= estimator;
        
        float exitProbability = clamp(throughput, 0.0, 1.0);
        if (random1() > exitProbability) {
            break;
        }
        throughput /= exitProbability;
    }
    
    return L;
}

vec3 convertToEarthSpace(vec3 x) {
    x.y += earthRadius + max(1.0, 1.0 + renderState.altitude + 64.0);
    x -= renderState.cameraPosition;
    return x;
}

ray convertToEarthSpace(ray r) {
    r.origin = convertToEarthSpace(r.origin);
    return r;
}

#endif // _ATMOSPHERE_PATHTRACER_GLSL