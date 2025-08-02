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

#ifndef _ATMOSPHERE_DENSITY_GLSL
#define _ATMOSPHERE_DENSITY_GLSL 1

#include "/lib/atmosphere/constants.glsl"

float airDensity(float x) {
    return 2.50844 / (1.0 + exp(0.000159087 * x + 0.0691795));
}

float aerosolDensity(float x) {
    if (x < 0.0) {
        return 0.0;
    }
    
    float c = 0.0;
    if (x < 1855.0) {
        c = ((((-1.37232e-9) * x + 0.00000399595) * x - 0.00362987) * x - 0.0895921) * x + 10027.7162;
    } else if (x < 2665.0) {
        c = 1.07158e14 * pow(x, -3.12345);
    } else if (x < 10275.0) {
        c = 2935.81129 * pow(0.999881, x);
    } else {
        c = 892.89874 / (1.0 + exp(-(-0.0019755 * x + 23.706)));
    }
    return 1.0e-3 * c * 1.0e-4;
}

// Ozone density fit by FordPerfect
// https://www.shadertoy.com/view/XcKSzd
float ozoneDensity(float x) {
    if (x < 0.0 || x > 74000.0) {
        return 0.0;
    }

    return exp((((-1.2272e-18 * 
        x + 2.6322e-13) * x - 2.2212e-8) * 
        x + 6.3885e-4) * x + 3.7199e+1) + 
        exp(-2.1512e-4 * x + 41.491);
}

vec3 atmosphereDensity(float height) {
    height -= earthRadius;
    return vec3(airDensity(height), aerosolDensity(height), ozoneDensity(height));
}

vec3 maxAtmosphereDensity() {
    return vec3(airDensity(0.0), aerosolDensity(0.0), ozoneDensity(22000.0));
}

#endif // _ATMOSPHERE_DENSITY_GLSL