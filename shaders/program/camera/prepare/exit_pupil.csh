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

#include "/lib/buffer/spectral.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/lens/tracing.glsl"

layout (local_size_x = 32, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(8, 1, 1);

void main() {
    vec2 sensorExtent = getSensorPhysicalExtent(CAMERA_SENSOR);
    float physicalRadius = length(sensorExtent);

    float sampleRadius = physicalRadius * float(gl_GlobalInvocationID.x) / 255.0;
    vec3 filmPoint = vec3(sampleRadius, 0.0, 0.0);

    vec2 boundMin = vec2(10000.0);
    vec2 boundMax = vec2(-10000.0);
    int N = 0;

    float rearRadius = rearLensElement().aperture * 1.5;

    if (renderState.frame == 1) {
        float zRear = rearLensElementZ();
        for (int i = 0; i < 256; i++) {
            for (int j = 0; j < 256; j++) {
                vec3 pointRear = vec3(mix(vec2(-rearRadius), vec2(rearRadius), vec2(i, j) / 255.0), zRear);
                if (clamp(pointRear.xy, boundMin, boundMax) == pointRear.xy) {
                    continue;
                }

                vec3 direction = normalize(pointRear - filmPoint);
                ray r = ray(filmPoint, direction);
                if (rayExitsLensSystem(550, r) || rayExitsLensSystem(WL_MIN, r) || rayExitsLensSystem(WL_MAX, r)) {
                    float spacing = physicalRadius / 255.0;
                    boundMin = min(boundMin, pointRear.xy - spacing);
                    boundMax = max(boundMax, pointRear.xy + spacing);
                    N++;
                }
            }
        }
    }

    if (renderState.frame <= 1) {
        if (N == 0) {
            boundMin = vec2(-rearRadius);
            boundMax = vec2(rearRadius);
        }

        renderState.exitPupil.samples[gl_GlobalInvocationID.x] = pupil_bounds(boundMin, boundMax);
    }
}
