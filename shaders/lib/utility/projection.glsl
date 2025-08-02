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

#ifndef _PROJECTION_GLSL
#define _PROJECTION_GLSL 1

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homogeneous = projectionMatrix * vec4(position, 1.0);
    return homogeneous.xyz / homogeneous.w;
}

#endif // _PROJECTION_GLSL