#ifndef _METALS_GLSL
#define _METALS_GLSL 1

// metals/iron: 89 entries
// metals/gold: 89 entries
// metals/aluminium: 89 entries
// metals/chrome: 89 entries
// metals/copper: 89 entries
// metals/lead: 89 entries
// metals/platinum: 89 entries
// metals/silver: 89 entries

layout (std430, binding = 4) buffer metal_data {
    vec2 iors[];
} metalData;

vec2 getMeasuredMetalIOR(int lambda, int id) {
    int lowerIndex = (lambda - WL_MIN) / 5;
    int upperIndex = lowerIndex + 1;
    float t = float(lambda - WL_MIN - lowerIndex * 5) / 5.0;
    return mix(metalData.iors[lowerIndex + id * 89], metalData.iors[upperIndex + id * 89], t);
}

#endif