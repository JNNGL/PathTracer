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

#ifndef _TONEMAP_GLSL
#define _TONEMAP_GLSL 1

#include "/lib/post/aces.glsl"
#include "/lib/post/agx.glsl"
#include "/lib/post/camera_tonemap.glsl"
#include "/lib/settings.glsl"

vec3 tonemap(vec3 color) {
#if (TONEMAP == 0)
    return agxTonemap(color);
#elif (TONEMAP == 1)
    return cameraTonemap(color, 4.0);
#elif (TONEMAP == 2)
    return clamp(1.0 - exp(-color), 0.0, 1.0);
#elif (TONEMAP == 3)
    return acesFitted(color);
#endif
}

#endif // _TONEMAP_GLSL