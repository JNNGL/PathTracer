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

#ifndef _FILM_GLSL
#define _FILM_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/settings.glsl"

layout (rgba32f) uniform image2D filmBuffer;
layout (rgba32f) uniform image2D splatBuffer;
layout (r32ui) uniform uimage2D lockBuffer;

uniform sampler2D filmSampler;
uniform sampler2D splatSampler;

vec3 getFilmAverageColor(vec2 coord) {
    coord = coord * 0.5 + 0.5;
    vec3 splat = texture(splatSampler, coord).xyz / float(max(renderState.frame, 1));
    return texture(filmSampler, coord).xyz + splat;
}

vec3 getFilmAverageColor(vec2 coord, ivec2 offset) {
    coord = coord * 0.5 + 0.5 + vec2(offset) / vec2(textureSize(filmSampler, 0).xy);
    vec3 splat = texture(splatSampler, coord).xyz / float(max(renderState.frame, 1));
    return texture(filmSampler, coord).xyz + splat;
}

vec3 getFilmAverageColor(ivec2 coord) {
    vec3 splat = texelFetch(splatSampler, coord, 0).xyz / float(max(renderState.frame, 1));
    return texelFetch(filmSampler, coord, 0).xyz;
}

bool spinlockAcquire(ivec2 coord) {
    return imageAtomicCompSwap(lockBuffer, coord, 0u, 1u) == 0u;
}

void spinlockRelease(ivec2 coord) {
    imageAtomicExchange(lockBuffer, coord, 0u);
}

void logFilmSplat(ivec2 coord, vec3 L) {
    for (int i = 0;; i++) {
        if (spinlockAcquire(coord)) {
            imageStore(splatBuffer, coord, vec4(imageLoad(splatBuffer, coord).xyz + L, 0.0));
            spinlockRelease(coord);
            return;
        }
        if (i >= 512) {
            renderState.invalidSplat = 1;
            return;
        }
    }
}

void logFilmSample(ivec2 coord, vec3 L) {
    vec4 data = imageLoad(filmBuffer, coord);

    data.w += 1.0;

    data.xyz = mix(data.xyz, L, 1.0 / float(data.w));
    imageStore(filmBuffer, coord, data);
}

void logFilmSplat(vec2 coord, vec3 L) {
    ivec2 size = imageSize(filmBuffer);
    ivec2 imageCoord = ivec2((coord * 0.5 + 0.5) * size);

    logFilmSplat(imageCoord, L);
}

void logFilmSample(vec2 coord, vec3 L) {
    ivec2 size = imageSize(filmBuffer);
    ivec2 imageCoord = ivec2((coord * 0.5 + 0.5) * size);

    logFilmSample(imageCoord, L);
}

#endif // _FILM_GLSL