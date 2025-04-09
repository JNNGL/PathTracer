#ifndef _LENS_CAMERA_GLSL
#define _LENS_CAMERA_GLSL 1

#include "/lib/lens/tracing.glsl"
#include "/lib/lens/sampling.glsl"

ray generateCameraRay(int lambda, vec3 position, mat4 projection, mat4 viewInverse, vec2 filmSample, out float weight, out bool lensFlare) {
    const float lensFlareProbability = 0.25;

    vec2 sensorExtent = getSensorPhysicalExtent(CAMERA_SENSOR, projection);

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
    float distanceTerm = length(targetPoint - originPoint);

    ray r = ray(originPoint, (targetPoint - originPoint) / distanceTerm);
    weight *= (r.direction.z * r.direction.z) / (distanceTerm * distanceTerm);

    if (!traceLensSystemFromFilm(lambda, !samplePupil, r, weight, lensFlare)) {
        weight = 0.0;
        return r;
    }

    if ((!samplePupil && !lensFlare) || isinf(weight) || isnan(weight)) {
        weight = 0.0;
    }

    r.origin = (mat3(viewInverse) * r.origin).xyz + position;
    r.direction = normalize((mat3(viewInverse) * r.direction).xyz);

    return r;
}

vec3 connectLightRayToFilm(int lambda, vec3 direction, mat4 projection, mat4 view, mat4 viewInverse, vec3 position, out bool lensFlare) {
    vec2 sensorExtent = getSensorPhysicalExtent(CAMERA_SENSOR, projection);

    direction = normalize(mat3(view) * direction);
    if (direction.z <= 0.0) {
        return vec3(0.0);
    }

    ray r = ray(position, direction);
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

#endif // _LENS_CAMERA_GLSL