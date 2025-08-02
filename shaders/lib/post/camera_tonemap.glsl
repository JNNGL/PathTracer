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

#ifndef _CAMERA_TONEMAP_GLSL
#define _CAMERA_TONEMAP_GLSL 1

#include "/lib/buffer/camera_response.glsl"

vec3 cameraTonemap(vec3 intensity, float iso) {
    intensity = clamp(intensity, 0.0, iso) / iso;
    intensity = vec3(
        binarySearchCameraResponse(0, intensity.x),
        binarySearchCameraResponse(1, intensity.y),
        binarySearchCameraResponse(2, intensity.z)
    );
    return clamp(intensity, 0.0, 1.0);
}

#endif // _CAMERA_TONEMAP_GLSL