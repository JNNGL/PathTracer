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

#ifndef _SUN_GLSL
#define _SUN_GLSL 1

#include "/lib/atmosphere/constants.glsl"
#include "/lib/buffer/solar_irradiance.glsl"
#include "/lib/buffer/spectral.glsl"
#include "/lib/spectral/blackbody.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/utility/time.glsl"

vec3 getMinecraftSunPosition(vec3 sunDirection) {
    return astronomicalUnit * normalize(sunDirection);
}

// https://www.sciencedirect.com/science/article/pii/S0960148121004031
vec3 getRealisticSunPosition(datetime dt, vec2 coordinates) {
    int dayOfYear = dt.day;
    for (int i = 1; i < dt.month; i++) {
        dayOfYear += daysInMonth(i, dt.year);
    }

    int nLeap = getLeapYears(dt.year) - getLeapYears(2000);
    float time = float(dt.hour) + float(dt.minute) / 60.0 + float(dt.second) / 3600.0;

    float n = -1.5 + float(dt.year - 2000) * 365.0 + float(nLeap + dayOfYear) + time / 24.0;
    float L = mod(280.460 + 0.9856474 * n, 360.0);
    float g = mod(357.528 + 0.9856003 * n, 360.0);
    float lambda = mod(L + 1.915 * sin(radians(g)) + 0.020 * sin(2.0 * radians(g)), 360.0);
    float epsilon = 23.439 - 0.0000004 * n;
    float alpha = mod(degrees(atan(cos(radians(epsilon)) * sin(radians(lambda)), cos(radians(lambda)))), 360.0);
    float delta = degrees(asin(sin(radians(epsilon)) * sin(radians(lambda))));
    float R = 1.00014 - 0.01671 * cos(radians(g)) - 0.00014 * cos(2.0 * radians(g));
    float EoT = mod((L - alpha) + 180.0, 360.0) - 180.0;

    float sunLatitude = delta;
    float sunLongitude = -15.0 * (time - 12.0 + EoT * 4.0 / 60.0);
    float phi_o = radians(coordinates.x);
    float phi_s = radians(sunLatitude);
    float lambda_o = radians(coordinates.y);
    float lambda_s = radians(sunLongitude);
    float Sx = cos(phi_s) * sin(lambda_s - lambda_o);
    float Sy = cos(phi_o) * sin(phi_s) - sin(phi_o) * cos(phi_s) * cos(lambda_s - lambda_o);
    float Sz = sin(phi_o) * sin(phi_s) + cos(phi_o) * cos(phi_s) * cos(lambda_s - lambda_o);

    return vec3(Sx, Sz, -Sy) * (R * astronomicalUnit);
}

vec3 sampleSunDirection(vec2 rand, vec3 sunPosition, vec3 x, out float weight) {
    vec3 centerDirection = normalize(sunPosition - x);
    
    vec3 b1, b2;
    buildOrthonormalBasis(centerDirection, b1, b2);
    
    vec2 pLocal = sunRadius * sampleDisk(rand);
    vec3 point = pLocal.x * b1 + pLocal.y * b2 + sunPosition;
    float pDistance = distance(point, x);
    
    vec3 sampleDirection = (point - x) / pDistance;
    
    float diskArea = sunRadius * sunRadius * PI;
    weight = diskArea * dot(sampleDirection, centerDirection) / (pDistance * pDistance);
    
    return sampleDirection;
}

// https://www.nrel.gov/grid/solar-resource/spectra-astm-e490
float getSunRadiance(float wavelength) {
    return solarIrradiance.data[clamp(int(wavelength), WL_MIN, WL_MAX) - WL_MIN] * 1000.0 / (2.0 * PI);
}

#endif // _SUN_GLSL