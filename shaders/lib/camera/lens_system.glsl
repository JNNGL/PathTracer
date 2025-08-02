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

#ifndef _CAMERA_LENS_SYSTEM_GLSL
#define _CAMERA_LENS_SYSTEM_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/lens/tracing.glsl"
#include "/lib/lens/sampling.glsl"

ray generateCameraRay(int lambda, vec2 filmSample, out float weight, out bool lensFlare) {
    const float lensFlareProbability = 0.25;

    vec2 sensorExtent = getSensorPhysicalExtent(CAMERA_SENSOR);

    vec2 pointOnSensor = sensorExtent * -filmSample;
    vec2 pointOnRearElement;

    bool samplePupil = random1() >= lensFlareProbability;
    if (samplePupil) {
        pointOnRearElement = sampleExitPupil(random2(), pointOnSensor, sensorExtent, weight);
        weight /= (1.0 - lensFlareProbability);
    } else {
        pointOnRearElement = samplePointOnRearElement(random2(), weight);
        weight /= lensFlareProbability;
    }

    vec3 targetPoint = vec3(pointOnRearElement, rearLensElementZ());
    vec3 originPoint = vec3(pointOnSensor, 0.0);
    float ppDistance = length(targetPoint - originPoint);

    ray r = ray(originPoint, (targetPoint - originPoint) / ppDistance);
    weight *= (r.direction.z * r.direction.z) / (ppDistance * ppDistance);

    if (!traceLensSystemFromFilm(lambda, !samplePupil, r, weight, lensFlare)) {
        weight = 0.0;
        return r;
    }

    if ((!samplePupil && !lensFlare) || isinf(weight) || isnan(weight)) {
        weight = 0.0;
    }

    r.origin = (mat3(renderState.viewMatrixInverse) * r.origin) + renderState.cameraPosition;
    r.direction = normalize(mat3(renderState.viewMatrixInverse) * r.direction);

    return r;
}

vec3 connectLightRayToFilm(int lambda, vec3 direction, out bool lensFlare) {
    vec2 sensorExtent = getSensorPhysicalExtent(CAMERA_SENSOR);

    direction = normalize(mat3(renderState.viewMatrix) * direction);
    if (direction.z <= 0.0) {
        return vec3(0.0);
    }

    ray r = ray(renderState.cameraPosition, direction);
    r.origin -= 0.1 * direction;

    float weight = 1.0;
    if (!traceLensSystemFromScene(lambda, true, r, weight, lensFlare)) {
        return vec3(0.0);
    }

    weight /= (sensorExtent.x * sensorExtent.y * 4.0);

    float t = -r.origin.z / r.direction.z;
    r.origin += t * r.direction;

    vec2 pointOnSensor = r.origin.xy / sensorExtent;
    if (clamp(pointOnSensor, -1.0, 1.0) != pointOnSensor) {
        weight = 0.0;
    }

    weight *= r.direction.z;
    return vec3(-pointOnSensor, weight);
}

#endif // _CAMERA_LENS_SYSTEM_GLSL