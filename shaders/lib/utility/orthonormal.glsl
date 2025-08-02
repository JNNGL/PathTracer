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

#ifndef _ORTHONORMAL_GLSL
#define _ORTHONORMAL_GLSL 1

// https://backend.orbit.dtu.dk/ws/portalfiles/portal/126824972/onb_frisvad_jgt2012_v2.pdf

void buildOrthonormalBasis(vec3 n, out vec3 b1, out vec3 b2) {
    if (n.z < -0.9999999) {
        b1 = vec3(0.0, -1.0, 0.0);
        b2 = vec3(-1.0, 0.0, 0.0);
    } else {
        float a = 1.0 / (1.0 + n.z);
        float b = -n.x * n.y * a;
        b1 = vec3(1.0 - n.x * n.x * a, b, -n.x);
        b2 = vec3(b, 1.0 - n.y * n.y * a, -n.y);
    }
}

#endif // _ORTHONORMAL_GLSL