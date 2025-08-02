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

#ifndef _LENS_INTERSECTION_GLSL
#define _LENS_INTERSECTION_GLSL 1

#include "/lib/raytracing/ray.glsl"

bool intersectSphericalLensElement(float radius, float z, ray r, out float t, out vec3 normal) {
    r.origin -= vec3(0.0, 0.0, z + radius);

    float b = dot(r.origin, r.direction);
    float c = dot(r.origin, r.origin) - radius * radius;
    float d = b * b - c;
    if (d < 0.0) {
        return false;
    }

    d = sqrt(d);
    float t0 = -b - d;
    float t1 = -b + d;
    t = radius * r.direction.z > 0.0 ? t0 : t1;
    
    normal = normalize(r.origin + t * r.direction);
    normal *= -sign(dot(r.direction, normal));

    return true;
}

bool intersectPlanarLensElement(float z, ray r, out float t, out vec3 normal) {
    t = (z - r.origin.z) / r.direction.z;
    normal = vec3(0.0, 0.0, -sign(r.direction.z));
    return t >= 0.0;
}

#endif // _LENS_INTERSECTION_GLSL