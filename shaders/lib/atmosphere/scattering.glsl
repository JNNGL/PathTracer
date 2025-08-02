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

#ifndef _ATMOSPHERE_SCATTERING_GLSL
#define _ATMOSPHERE_SCATTERING_GLSL 1

#include "/lib/utility/constants.glsl"
#include "/lib/utility/orthonormal.glsl"

float airRefractiveIndex(float lambda) {
    lambda /= 1000.0;
    float ns = 5791817.0 / (238.0185 - 1.0 / (lambda * lambda)) + 167909.0 / (57.362 - 1.0 / (lambda * lambda));
    return ns / 1.0e8 + 1.0;
}

float depolarizationFactor(float lambda) {
    float x = lambda / 1000.0;
    return ((((-5.20398 * x + 8.31652) * x - 2.3355) * x - 2.0086) * x + 3.72696) * 1.0e-2;
}

float rayleighScatteringBeta(float lambda, float n) {
    const float N = 2.545e25;
    
    float pn = depolarizationFactor(lambda);
    
    lambda *= 1.0e-9;
    float a = n * n - 1.0;
    float k = (6.0 + 3.0 * pn) / (6.0 - 7.0 * pn);
    
    float lambda2 = lambda * lambda;
    return k * 8.0 * PI * PI * PI * a * a / (3.0 * N * lambda2 * lambda2);
}

float mieScatteringBeta(float lambda, float turbidity) {
    const float v = 4.0;
    
    float c = (0.6544 * turbidity - 0.6510) * 1.0e-16;
    
    float x = lambda / 1000.0;
    float K = (((-1.26852 * x + 3.51896) * x - 3.76305) * x + 1.87791) * x + 0.313775;
    
    lambda *= 1.0e-9;
    return 0.434 * c * PI * pow(2.0 * PI / lambda, v - 2.0) * K;
}

float rayleighPhase(float cosTheta, float lambda) {
    float pn = depolarizationFactor(lambda);
    float gamma = pn / (2.0 - pn);
    return 3.0 / (16.0 * PI * (1.0 + 2.0 * gamma)) * (1.0 + 3.0 * gamma + (1.0 - gamma) * cosTheta * cosTheta);
}

// https://research.nvidia.com/labs/rtr/approximate-mie/publications/approximate-mie.pdf
// https://research.nvidia.com/labs/rtr/approximate-mie/publications/approximate-mie-supplemental.pdf
void hgDraineParams(float d, out float gHG, out float gD, out float a, out float wD) {
    if (d <= 0.1) {
        gHG = 13.8 * d * d;
        gD = 1.1456 * d * sin(9.29044 * d);
        a = 250.0;
        wD = 0.252977 - 312.983 * pow(d, 4.3);
    } else if (d < 1.5) {
        float logd = log(d);
        gHG = 0.862 - 0.143 * logd * logd;
        gD = 0.379685 * cos(1.19692 * 
            cos((logd - 0.238604) * (logd + 1.00667) / (0.507522 - 0.15677 * logd)) + 
            1.37932 * logd + 0.0625835) + 0.344213;
        a = 250.0;
        wD = 0.146209 * cos(3.38707 * logd + 2.11193) + 0.316072 + 0.0778917 * logd;
    } else if (d < 5.0) {
        float logd = log(d);
        gHG = 0.0604931 * log(logd) + 0.940256;
        gD = 0.500411 - 0.081287 / (-2.0 * logd + tan(logd) + 1.27551);
        a = 7.30354 * logd + 6.31675;
        wD = 0.026914 * (logd - cos(5.68947 * (log(logd) - 0.0292149))) + 0.376475;
    } else if (d < 50.0) {
        gHG = exp(-0.0990567 / (d - 1.67154));
        gD = exp(-2.20679 / (d + 3.91029) - 0.428934);
        a = exp(3.62489 - 8.29288 / (d + 5.52825));
        wD = exp(-0.599085 / (d - 0.641583) - 0.665888);
    }
}

float drainePhase(float cosTheta, float a, float g) {
    float n1 = (1.0 - g * g) / pow(1.0 + g * g - 2.0 * g * cosTheta, 1.5);
    float n2 = (1.0 + a * cosTheta * cosTheta) / (1.0 + a * (1.0 + 2.0 * g * g) / 3.0);
    return n1 * n2 / (4.0 * PI);
}

float hgDrainePhase(float cosTheta, float d) {
    float gHG, gD, a, wD;
    hgDraineParams(d, gHG, gD, a, wD);

    return (1.0 - wD) * drainePhase(cosTheta, 0.0, gHG) + wD * drainePhase(cosTheta, a, gD);
}

float sampleHenyeyGreenstein(float rand, float g) {
    float t = (1.0 - g * g) / (1.0 - g + 2.0 * g * rand);
    return (1.0 + g * g - t) / (2.0 * g);
}

float sampleDraine(float rand, float g, float a) {
    float t0 = a - a * g * g;
    float t1 = a * g * g * g * g - a;
    float t2 = -3.0 * (4.0 * (g * g * g * g - g * g) + t1 * (1.0 + g * g));
    float t3 = g * (2.0 * rand - 1.0);
    float t4 = 3.0 * g * g * (1.0 + t3) + a * (2.0 + g * g * (1.0 + (1.0 + 2.0 * g * g) * t3));
    float t5 = t0 * (t1 * t2 + t4 * t4) + t1 * t1 * t1;
    float t6 = t0 * 4.0 * (g * g * g * g - g * g);
    float t7 = pow((t5 + sqrt(t5 * t5 - t6 * t6 * t6)), 1.0 / 3.0);
    float t8 = 2.0 * (t1 + t6 / t7 + t7) / t0;
    float t9 = sqrt(6.0 * (1.0 + g * g) + t8);
    return g / 2.0 + (1.0 / (2.0 * g) - 1.0 / (8.0 * g) * pow(
        sqrt(6.0 * (1.0 + g * g) - t8 + 8.0 * t4 / (t0 * t9)) - t9, 2.0));
}

vec3 sampleHgDraine(vec3 w, vec3 rand, float d) {
    float gHG, gD, a, wD;
    hgDraineParams(d, gHG, gD, a, wD);

    float cosTheta;
    if (rand.z < wD) {
        cosTheta = sampleDraine(rand.x, gD, a);
    } else {
        cosTheta = sampleHenyeyGreenstein(rand.x, gHG);
    }
    
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    float phi = 2.0 * PI * rand.y;
    vec3 spherical = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
    
    vec3 b1, b2;
    buildOrthonormalBasis(w, b1, b2);
    
    return normalize(b1 * spherical.x + b2 * spherical.y + w * spherical.z);
}

// Ozone absorption fit by FordPerfect
// https://www.shadertoy.com/view/XcKSzd
float ozoneAbsorption(float x) {
    if (x > 213.0 && x < 380.0) {
        return exp(-1632.43483 + x * (27.2816384 + 
            x * (-0.188136709 + x * (0.000652848908 +
            x * (-1.13680875e-06 + x * (7.90050380e-10))))));
    }
    if (x >= 380.0 && x <= 780.0) {
        return exp(-178.194363 + x * (1.07246495 + 
            x * (-0.00403429758 + x * (8.14291496e-06 + 
            x * (-8.30370951e-09 + x * 3.31168412e-12))))) +
            exp(0.1 * min(603.0 - x, 0.0) + 0.02 * x - 60.414287) * 
            (exp(0.5 * cos(0.19039955476 * x - 114.810931522)) - 1.0);
    }
    if (x > 780.0) {
        return exp(-36.6867555 - x * 0.0162778335);
    }
    return 0.0;
}

vec3 atmosphereExtinctionBeta(float wavelength) {
    float ns = airRefractiveIndex(wavelength);

    float betaR = rayleighScatteringBeta(wavelength, ns);
    float betaM = mieScatteringBeta(wavelength, atmosphereTurbidity);
    float sigmaO = ozoneAbsorption(wavelength);

    return vec3(betaR, 1.1 * betaM, 0.0001 * sigmaO);
}

#endif // _ATMOSPHERE_SCATTERING_GLSL
