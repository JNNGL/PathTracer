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

#ifndef _STATE_GLSL
#define _STATE_GLSL 1

#include "/lib/entity/structures.glsl"
#include "/lib/utility/time.glsl"

struct pupil_bounds {
    vec2 minBound;
    vec2 maxBound;
};

struct exit_pupil_data {
    pupil_bounds samples[256];
};

layout (std430, binding = 1) buffer render_state {
    bool clear;
    int frame;
    float lensFrontZ;
    float focusDistance;
    float rearThicknessDelta;
    exit_pupil_data exitPupil;
    float entracePupilRadius;
    float focalLength;
    float apertureRadius;
    float fNumber;
    mat2 rayTransferMatrix;
    ivec2 startTime;
    datetime localTime;
    vec3 sunDirection;
    vec3 sunPosition;
    int invalidSplat;
    uint histogram[256];
    float avgLuminance;
    mat4 projection;
    mat4 projectionInverse;
    mat4 viewMatrix;
    mat4 viewMatrixInverse;
    vec3 cameraPosition;
    float altitude;
    entity_data entityData;
} renderState;

#endif // _STATE_GLSL