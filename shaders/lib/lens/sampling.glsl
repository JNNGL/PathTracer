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

#ifndef _LENS_SAMPLING_GLSL
#define _LENS_SAMPLING_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/utility/sampling.glsl"

vec3 samplePointOnFrontElement(vec2 rand, out float weight) {
    const float radiusMultiplier = 2.5;
    
    float aperture = frontLensElement().aperture;
    vec2 pointOnFront = aperture * sampleDisk(rand) * radiusMultiplier;
    weight = aperture * aperture * radiusMultiplier * radiusMultiplier * PI;

    return vec3(pointOnFront, frontLensElementZ());
}

vec2 samplePointOnRearElement(vec2 rand, out float weight) {
    const float radiusMultiplier = 1.5;

    float aperture = rearLensElement().aperture;
    weight = aperture * aperture * radiusMultiplier * radiusMultiplier * PI;

    return aperture * sampleDisk(rand) * radiusMultiplier;
}

vec2 sampleExitPupil(vec2 rand, vec2 pointOnSensor, vec2 sensorExtent, out float weight) {
    float sampleRadius = length(pointOnSensor);
    float physicalRadius = length(sensorExtent);
    float index = 255.0 * sampleRadius / physicalRadius;
    pupil_bounds bounds1 = renderState.exitPupil.samples[clamp(int(ceil(index)), 0, 255)];
    pupil_bounds bounds2 = renderState.exitPupil.samples[clamp(int(floor(index)), 0, 255)];
    pupil_bounds bounds = pupil_bounds(min(bounds1.minBound, bounds2.minBound), max(bounds1.maxBound, bounds2.maxBound));
    
    weight = (bounds.maxBound.x - bounds.minBound.x) * (bounds.maxBound.y - bounds.minBound.y);

    float sinTheta = pointOnSensor.y / sampleRadius;
    float cosTheta = pointOnSensor.x / sampleRadius;

    return mix(bounds.minBound, bounds.maxBound, rand) * mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
}

#endif // _LENS_SAMPLING_GLSL