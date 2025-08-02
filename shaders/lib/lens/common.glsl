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

#ifndef _LENS_COMMON_GLSL
#define _LENS_COMMON_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/reflection/sellmeier.glsl"
#include "/lib/settings.glsl"

struct sensor_data {
    float baseExtent;
};

struct lens_element {
    float curvature;
    float thickness;
    sellmeier_coeffs glass;
    float aperture;
    bool coated;
};

vec2 getSensorPhysicalExtent(sensor_data data) {
    float scale = float(SENSOR_SIZE) / 100.0;
    return scale * vec2(data.baseExtent) * 0.001 * vec2(1.0, renderState.projection[0][0] / renderState.projection[1][1]);
}

#endif // _LENS_COMMON_GLSL