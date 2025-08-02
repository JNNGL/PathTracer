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

#ifndef _METALS_GLSL
#define _METALS_GLSL 1

#include "/lib/buffer/spectral.glsl"
#include "/lib/complex/float.glsl"

// metals/iron: 89 entries
// metals/gold: 89 entries
// metals/aluminium: 89 entries
// metals/chrome: 89 entries
// metals/copper: 89 entries
// metals/lead: 89 entries
// metals/platinum: 89 entries
// metals/silver: 89 entries

layout (std430, binding = 4) readonly buffer metal_data {
    vec2 iors[];
} metalData;

complexFloat getMeasuredMetalIOR(int lambda, int id) {
    int lowerIndex = (lambda - WL_MIN) / 5;
    int upperIndex = lowerIndex + 1;
    float t = float(lambda - WL_MIN - lowerIndex * 5) / 5.0;
    return complexFloat(mix(metalData.iors[lowerIndex + id * 89], metalData.iors[upperIndex + id * 89], t));
}

#endif // _METALS_GLSL