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

#ifndef _SPECTRAL_GLSL
#define _SPECTRAL_GLSL 1

#define WL_MIN 390
#define WL_MAX 830

layout (std430, binding = 3) readonly buffer spectral_data {
    vec3 cie_cmf_xyz[441];
    vec3 cie_bt709_basis[391]; // https://github.com/geometrian/simple-spectral/blob/master/data/cie2006-basis-bt709-390%2B1%2B780.csv
    float illuminant_d65[97];
    float cie_y_integral;
} spectralData;

float CIE_Y_Integral() {
    return spectralData.cie_y_integral;
}

vec3 CIE_CMF_XYZ(int lambda) {
    if (lambda < 390 || lambda > 830) {
        return vec3(0.0);
    }
    return spectralData.cie_cmf_xyz[lambda - 390];
}

vec3 CIE_BT709_Basis(int lambda) {
    if (lambda < 390 || lambda > 780) {
        return vec3(0.0);
    }
    return spectralData.cie_bt709_basis[lambda - 390];
}

float Illuminant_D65(int lambda) {
    if (lambda < 300 || lambda >= 780) {
        return 0.0;
    }
    int index = (lambda - 300) / 5;
    float t = float((lambda - 300) - index * 5) / 5.0;
    return mix(spectralData.illuminant_d65[index], spectralData.illuminant_d65[index + 1], t);
}

#endif // _SPECTRAL_GLSL