#ifndef _ENVIRONMENT_GLSL
#define _ENVIRONMENT_GLSL 1

#include "/lib/buffer/bins.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/utility/constants.glsl"
#include "/lib/settings.glsl"

uniform sampler2D environment;

// I'll make a path traced atmosphere one day.
// http://karim.naaji.fr/environment_map_importance_sampling.html

float environmentMap(int lambda, vec3 rayDirection) {
    float u = atan(rayDirection.z, rayDirection.x) / (2.0 * PI);
    float v = acos(rayDirection.y) / PI;
    vec2 uv = fract(vec2(u + ENVMAP_OFFSET_U, v));

    vec3 rgb = texelFetch(environment, ivec2(uv * vec2(environmentMapSize)), 0).rgb;
    return lrgbToEmissionSpectrum(lambda, rgb);
}

float environmentMap(int lambda, ray r) {
    return environmentMap(lambda, r.direction);
}

vec3 sampleEnvironmentMap(vec3 u, out float pdf) {
    int binIndex = int(binBuffer.numBins * u.x);
    bin_data bin = binBuffer.bins[binIndex];

    float binWidth = float(bin.x1 - bin.x0);
    float binHeight = float(bin.y1 - bin.y0);

    vec2 uv = vec2(
        float(bin.x0) + u.y * binWidth,
        float(bin.y0) + u.z * binHeight
    );

    uv /= vec2(environmentMapSize);
    uv.x -= ENVMAP_OFFSET_U;

    float phi = mod(uv.x * 2.0 * PI, 2.0 * PI);
    float theta = uv.y * PI;

    float sinTheta = max(sin(theta), 1.0e-10);
    vec3 sampleDir = vec3(cos(phi) * sinTheta, cos(theta), sin(phi) * sinTheta);

    float binArea = binWidth * binHeight;
    float binPDF = float(environmentMapSize.x * environmentMapSize.y) / (float(binBuffer.numBins) * binArea);
    pdf = binPDF / (2.0 * PI * PI * sinTheta);

    return sampleDir;
}

float environmentMapPDF(vec3 rayDirection) {
    float u = atan(rayDirection.z, rayDirection.x) / (2.0 * PI);
    float v = acos(rayDirection.y) / PI;
 
    vec2 uv = fract(vec2(u + ENVMAP_OFFSET_U, v));
    ivec2 coord = ivec2(uv * vec2(environmentMapSize));
    int pixelIndex = environmentMapSize.x * coord.y + coord.x;
    int binIndex = binBuffer.binIndexes[pixelIndex];
    bin_data bin = binBuffer.bins[binIndex];
 
    float binWidth = float(bin.x1 - bin.x0);
    float binHeight = float(bin.y1 - bin.y0);

    float theta = uv.y * PI;
    float sinTheta = max(sin(theta), 1.0e-10);
    float binArea = binWidth * binHeight;
    float binPDF = float(environmentMapSize.x * environmentMapSize.y) / (float(binBuffer.numBins) * binArea);
    return binPDF / (2.0 * PI * PI * sinTheta);
}

float environmentMapWeight(int lambda, vec3 rayDirection) {
    return environmentMapPDF(rayDirection);
}
float environmentMapWeight(int lambda, ray r) {
    return environmentMapWeight(lambda, r.direction);
}

#endif // _ENVIRONMENT_GLSL