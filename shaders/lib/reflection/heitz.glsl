// https://eheitzresearch.wordpress.com/240-2/
// Most of this code is adapted from the reference implementation.

#ifndef _HEITZ_GLSL
#define _HEITZ_GLSL 1

#include "/lib/reflection/fresnel.glsl"
#include "/lib/settings.glsl"

// Uniform height distribution
float height_P1(float h) {
    return (h >= -1.0 && h <= 1.0) ? 0.5 : 0.0;
}

float height_C1(float h) {
    return clamp(h * 0.5 + 0.5, 0.0, 1.0);
}

float height_invC1(float u) {
    return clamp(2.0 * u - 1.0, -1.0, 1.0);
}

// Microsurface Slope
float slope_P22(material m, float slope_x, float slope_y);
float slope_lambda(material m, vec3 wi);
float slope_projectedArea(material m, vec3 wi);
vec2 slope_sampleP22_11(float theta_i, vec2 U);

float slope_alpha_i(material m, vec3 wi) {
    float invSinTheta2 = 1.0 / (1.0 - wi.z * wi.z);
    float cosPhi2 = wi.x * wi.x * invSinTheta2;
    float sinPhi2 = wi.y * wi.y * invSinTheta2;
    return sqrt(cosPhi2 * m.alpha.x * m.alpha.x + sinPhi2 * m.alpha.y * m.alpha.y);
}

float slope_D(material m, vec3 wm) {
    if (wm.z <= 0.0) {
        return 0.0;
    }

    float slope_x = -wm.x / wm.z;
    float slope_y = -wm.y / wm.z;

    return slope_P22(m, slope_x, slope_y) / (wm.z * wm.z * wm.z * wm.z);
}

float slope_D_wi(material m, vec3 wi, vec3 wm) {
    if (wm.z <= 0.0) {
        return 0.0;
    }

    float projectedArea = slope_projectedArea(m, wi);
    if (projectedArea == 0.0) {
        return 0.0;
    }

    float c = 1.0 / projectedArea;

    return c * max(0.0, dot(wi, wm)) * slope_D(m, wm);
}

vec3 slope_sampleD_wi(material m, vec3 wi, vec2 U) {
    vec3 wi_11 = normalize(vec3(m.alpha.x * wi.x, m.alpha.y * wi.y, wi.z));

    vec2 slope_11 = slope_sampleP22_11(acos(wi_11.z), U);

    float phi = atan(wi_11.y, wi_11.x);
    vec2 slope = vec2(cos(phi) * slope_11.x - sin(phi) * slope_11.y, sin(phi) * slope_11.x + cos(phi) * slope_11.y);

    slope.x *= m.alpha.x;
    slope.y *= m.alpha.y;

    if (isnan(slope.x) || isinf(slope.x)) {
        if (wi.z > 0.0) {
            return vec3(0.0, 0.0, 1.0);
        } else {
            return normalize(vec3(wi.x, wi.y, 0.0));
        }
    }

    vec3 wm = normalize(vec3(-slope.x, -slope.y, 1.0));
    return wm;
}

// GGX Distribution
float slope_P22(material m, float slope_x, float slope_y) {
    float tmp = 1.0 + slope_x * slope_x / (m.alpha.x * m.alpha.x) + slope_y * slope_y / (m.alpha.y * m.alpha.y);
    return 1.0 / (PI * m.alpha.x * m.alpha.y * tmp * tmp);
}

float slope_lambda(material m, vec3 wi) {
    if (wi.z > 0.9999) {
        return 0.0;
    }
    if (wi.z < -0.9999) {
        return -1.0;
    }

    float theta_i = acos(wi.z);
    float a = 1.0 / (tan(theta_i) * slope_alpha_i(m, wi));

    return 0.5 * (-1.0 + sign(a) * sqrt(1.0 + 1.0 / (a * a)));
}

float slope_projectedArea(material m, vec3 wi) {
    if (wi.z > 0.9999) {
        return 1.0;
    }
    if (wi.z < -0.9999) {
        return 0.0;
    }

    float theta_i = acos(wi.z);
    float sin_theta_i = sin(theta_i);

    float alphai = slope_alpha_i(m, wi);

    return 0.5 * (wi.z + sqrt(wi.z * wi.z + sin_theta_i * sin_theta_i * alphai * alphai));
}

vec2 slope_sampleP22_11(float theta_i, vec2 U) {
    vec2 slope;

    if (theta_i < 0.0001) {
        float r = sqrt(U.x / (1.0 - U.x));
        float phi = PI * 2.0 * U.y;
        slope.x = r * cos(phi);
        slope.y = r * sin(phi);
        return slope;
    }

    float sin_theta_i = sin(theta_i);
    float cos_theta_i = cos(theta_i);
    float tan_theta_i = sin_theta_i / cos_theta_i;

    float slope_i = cos_theta_i / sin_theta_i;

    float projectedArea = cos_theta_i * 0.5 + 0.5;
    if (projectedArea < 0.0001 || isnan(projectedArea)) {
        return vec2(0.0, 0.0);
    }

    float c = 1.0 / projectedArea;

    float A = 2.0 * U.x / cos_theta_i / c - 1.0;
    float B = tan_theta_i;
    float tmp = 1.0 / (A * A - 1.0);

    float D = sqrt(max(0.0, B * B * tmp * tmp - (A * A - B * B) * tmp));
    float slope_x_1 = B * tmp - D;
    float slope_x_2 = B * tmp + D;
    slope.x = (A < 0.0 || slope_x_2 > 1.0 / tan_theta_i) ? slope_x_1 : slope_x_2;

    float U2;
    float S;
    if (U.y > 0.5) {
        S = 1.0;
        U2 = 2.0 * U.y - 1.0;
    } else {
        S = -1.0;
        U2 = 1.0 - 2.0 * U.y;
    }

    float z = (U2 * (U2 * (U2 * 0.27385 - 0.73369) + 0.46341)) / (U2 * (U2 * (U2 * 0.093073 + 0.309420) - 1.0) + 0.597999);
    slope.y = S * z * sqrt(1.0 + slope.x * slope.x);

    return slope;
}

// Microsurface
float G1(material m, vec3 wi, float h0) {
    if (wi.z > 0.9999) {
        return 1.0;
    }
    if (wi.z <= 0.0) {
        return 0.0;
    }

    float C1_h0 = height_C1(h0);
    float Lambda = slope_lambda(m, wi);
    return pow(C1_h0, Lambda);
}

float G1(material m, vec3 wi) {
    if (wi.z > 0.9999) {
        return 1.0;
    }
    if (wi.z <= 0.0) {
        return 0.0;
    }

    float Lambda = slope_lambda(m, wi);
    return 1.0 / (1.0 + Lambda);
}

float sampleMicrosurfaceHeight(material m, vec3 wr, float hr, float U) {
    if (wr.z > 0.9999) {
        return 3.402823466e+38;
    }
    if (wr.z < -0.9999) {
        return height_invC1(U * height_C1(hr));
    }

    if (abs(wr.z) < 0.0001) {
        return hr;
    }

    if (U > 1.0 - G1(m, wr, hr)) {
        return 3.402823466e+38;
    }

    return height_invC1(
        height_C1(hr) / pow((1.0 - U), 1.0 / slope_lambda(m, wr))
    );
}

#include "/lib/reflection/phase.glsl"

float evalMicrosurfaceBSDF(material m, vec3 wi, vec3 wo) {
    if (wo.z < 0.0) {
        return 0.0;
    }

    vec3 wr = -wi;
    float hr = 1.0 + height_invC1(0.999);

    float sum = 0.0;

    float throughput = 1.0;
    for (int i = 0; i < 64; i++) {
        hr = sampleMicrosurfaceHeight(m, wr, hr, random1());

        if (hr == 3.402823466e+38) {
            break;
        }

        float phaseFunction = evalMicrofacetPhase(m, -wr, wo);
        float shadowing = G1(m, wo, hr);
        float I = phaseFunction * shadowing;

        if (!isinf(I)) {
            sum += throughput * I;
        }

#ifdef BSDF_EVAL_RUSSIAN_ROULETTE
        float probability = min(1.0, throughput);
        if (random1() > probability) {
            break;
        }
        throughput /= probability;
#endif

        float weight;
        if (!sampleMicrofacetPhase(m, -wr, wr, weight)) {
            break;
        }
        throughput *= weight;

        if (isnan(hr) || isnan(wr.z)) {
            return 0.0;
        }
    }
    
    return sum;
}

bool sampleMicrosurfaceBSDF(material m, vec3 wi, out vec3 wo, out float throughput) {
    vec3 wr = -wi;
    float hr = 1.0 + height_invC1(0.999);

    throughput = 1.0;
    for (int i = 0; i <= 64; i++) {
        hr = sampleMicrosurfaceHeight(m, wr, hr, random1());

        if (hr == 3.402823466e+38) {
            wo = wr;
            return true;
        }

        float weight;
        if (!sampleMicrofacetPhase(m, -wr, wr, weight)) {
            break;
        }
        throughput *= weight;

        if (isnan(hr) || isnan(wr.z)) {
            break;
        }

#ifdef BSDF_SAMPLE_RUSSIAN_ROULETTE
        float probability = min(1.0, throughput);
        if (random1() > probability) {
            break;
        }
        throughput /= probability;
#endif
    }

    return false;
}

float evalMicrosurfacePDF(material m, vec3 wi, vec3 wo) {
    vec3 wh = normalize(wi + wo);
    if (m.type == MATERIAL_INTERFACED) {
        float fresnelIn = fresnelDielectric(dot(wi, wh), 1.0, m.ior.x);
        return fresnelIn * slope_D(m, wh) * G1(m, wi) / abs(4.0 * wi.z) + (1.0 - fresnelIn) * abs(wo.z) / PI + 0.001;
    } else if (m.type == MATERIAL_METAL) {
        return slope_D(m, wh) * G1(m, wi) / abs(4.0 * wi.z) + abs(wo.z) + 0.001;
    } else {
        return 1.0 / (2.0 * PI);
    }
}

#endif // _HEITZ_GLSL