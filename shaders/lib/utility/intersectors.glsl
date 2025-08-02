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

#ifndef _INTERSECTORS_GLSL
#define _INTERSECTORS_GLSL 1

#include "/lib/raytracing/ray.glsl"

vec2 intersectSphere(ray r, vec3 center, float radius) {
    vec3 oc = r.origin - center;
    float b = dot(oc, r.direction);
    vec3 qc = oc - b * r.direction;
    float h = radius * radius - dot(qc, qc);
    if(h < 0.0) {
        return vec2(-1.0);
    }

    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

#endif // _INTERSECTORS_GLSL