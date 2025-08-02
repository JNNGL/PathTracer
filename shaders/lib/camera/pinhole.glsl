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

#ifndef _PINHOLE_GLSL
#define _PINHOLE_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/projection.glsl"

ray generatePinholeCameraRay(vec2 filmSample) {
    vec3 pNear = projectAndDivide(renderState.projectionInverse, vec3(filmSample, -1.0));
    vec3 pDirection = projectAndDivide(renderState.projectionInverse, vec3(filmSample, 1.0));

    vec3 near = (renderState.viewMatrixInverse * vec4(pNear, 1.0)).xyz;
    vec3 direction = normalize((renderState.viewMatrixInverse * vec4(pDirection, 1.0)).xyz);

    return ray(renderState.cameraPosition + near, direction);
}

#endif // _PINHOLE_GLSL