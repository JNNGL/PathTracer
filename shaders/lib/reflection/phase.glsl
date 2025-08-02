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

#ifndef _MICROSURFACE_PHASE_GLSL
#define _MICROSURFACE_PHASE_GLSL 1

// Conductor Microsurface
float evalConductorMicrosurfacePhaseFunction(material m, vec3 wi, vec3 wo) {
    vec3 wh = normalize(wi + wo);
    if (wh.z < 0.0) {
        return 0.0;
    }

    return fresnelConductor(abs(dot(wi, wh)), complexFloat(currentIOR, 0.0), m.ior) * slope_D_wi(m, wi, wh) / (4.0 * dot(wi, wh));
}

vec3 sampleConductorMicrosurfacePhaseFunction(material m, vec3 wi, out float weight) {
    vec3 wm = slope_sampleD_wi(m, wi, random2());
    vec3 wo = reflect(-wi, wm);

    weight = fresnelConductor(abs(dot(wi, wm)), complexFloat(currentIOR, 0.0), m.ior);

    return wo;
}

vec3 sampleSmoothConductorPhaseFunction(material m, vec3 wi, out float weight) {
    weight = fresnelConductor(wi.z, complexFloat(currentIOR, 0.0), m.ior);
    return vec3(-wi.xy, wi.z);
}

// Diffuse Microsurface
float evalDiffuseMicrosurfacePhaseFunction(material m, vec3 wi, vec3 wo) {
    vec3 wm = slope_sampleD_wi(m, wi, random2());
    return m.albedo / PI * max(0.0, dot(wo, wm));
}

vec3 sampleDiffuseMicrosurfacePhaseFunction(material m, vec3 wi, out float weight) {
    weight = m.albedo;

    vec3 wm = slope_sampleD_wi(m, wi, random2());
    return sampleCosineWeightedHemisphere(random2(), wm);
}

float evalSmoothDiffusePhaseFunction(material m, vec3 wi, vec3 wo) {
    return m.albedo / PI * max(0.0, wo.z);
}

vec3 sampleSmoothDiffusePhaseFunction(material m, vec3 wi, out float weight) {
    weight = m.albedo;
    return sampleCosineWeightedHemisphere(random2());
}

// Interfaced Lambertian Microsurface
// https://hal.science/hal-01711532v1/document
float evalInterfacedMicrosurfacePhaseFunction(material m, vec3 wi, vec3 wo) {
    vec3 wm = slope_sampleD_wi(m, wi, random2());

    float fresnelIn = fresnelDielectric(abs(dot(wi, wm)), currentIOR, m.ior.x);
    float fresnelOut = fresnelDielectric(abs(dot(wo, wm)), currentIOR, m.ior.x);

    float ni = m.ior.x / currentIOR;
    float re = fresnelOverHemisphere(ni);
    float ri = 1.0 - (1.0 - re) / (ni * ni);
    float diffuse = (1.0 - fresnelIn) * (1.0 - fresnelOut) * m.albedo / PI / (ni * ni) * max(0.0, dot(wo, wm)) / (1.0 - m.albedo * ri);

    vec3 wh = normalize(wi + wo);
    if (wh.z < 0.0) {
        return diffuse;
    }

    float specular = fresnelDielectric(abs(dot(wi, wh)), currentIOR, m.ior.x) * slope_D_wi(m, wi, wh) / (4.0 * dot(wi, wh));
    return specular + diffuse;
}

vec3 sampleInterfacedMicrosurfacePhaseFunction(material m, vec3 wi, out float weight) {
    weight = 1.0;

    vec3 wm = slope_sampleD_wi(m, wi, random2());

    float fresnelIn = fresnelDielectric(abs(dot(wi, wm)), currentIOR, m.ior.x);
    float specularProb = fresnelIn / (fresnelIn + (1.0 - fresnelIn) * m.albedo);

    if (random1() < specularProb) {
        weight = fresnelIn / specularProb;
        return reflect(-wi, wm);
    } else {
        vec3 wo = sampleCosineWeightedHemisphere(random2(), wm);
        float fresnelOut = fresnelDielectric(abs(dot(wo, wm)), currentIOR, m.ior.x);
        float ni = m.ior.x / currentIOR;
        float re = fresnelOverHemisphere(ni);
        float ri = 1.0 - (1.0 - re) / (ni * ni);
        weight = (1.0 - fresnelIn) * (1.0 - fresnelOut) * m.albedo / (ni * ni) / (1.0 - specularProb) / (1.0 - m.albedo * ri);
        return wo;
    }
}

float evalSmoothInterfacedPhaseFunction(material m, vec3 wi, vec3 wo) {
    float fresnelIn = fresnelDielectric(wi.z, currentIOR, m.ior.x);
    float fresnelOut = fresnelDielectric(wo.z, currentIOR, m.ior.x);

    float ni = m.ior.x / currentIOR;
    float re = fresnelOverHemisphere(ni);
    float ri = 1.0 - (1.0 - re) / (ni * ni);
    return (1.0 - fresnelIn) * (1.0 - fresnelOut) * m.albedo / PI / (ni * ni) * max(0.0, wo.z) / (1.0 - m.albedo * ri);
}

vec3 sampleSmoothInterfacedPhaseFunction(material m, vec3 wi, out float weight, out bool dirac) {
    weight = 1.0;

    float fresnelIn = fresnelDielectric(wi.z, currentIOR, m.ior.x);
    float specularProb = fresnelIn / (fresnelIn + (1.0 - fresnelIn) * m.albedo);

    if (random1() < specularProb) {
        weight = fresnelIn / specularProb;
        dirac = true;
        return vec3(-wi.xy, wi.z);
    } else {
        vec3 wo = sampleCosineWeightedHemisphere(random2());
        float fresnelOut = fresnelDielectric(wo.z, currentIOR, m.ior.x);
        float ni = m.ior.x / currentIOR;
        float re = fresnelOverHemisphere(ni);
        float ri = 1.0 - (1.0 - re) / (ni * ni);
        weight = (1.0 - fresnelIn) * (1.0 - fresnelOut) * m.albedo / (ni * ni) / (1.0 - specularProb) / (1.0 - m.albedo * ri);
        dirac = false;
        return wo;
    }
}

// General Microfacet Phase Function
float evalMicrofacetPhase(material m, vec3 wi, vec3 wo) {
    if (m.type == MATERIAL_INTERFACED) {
        return evalInterfacedMicrosurfacePhaseFunction(m, wi, wo);
    } else if (m.type == MATERIAL_METAL) {
        return evalConductorMicrosurfacePhaseFunction(m, wi, wo);
    } else {
        return 0.0;
    }
}

bool sampleMicrofacetPhase(material m, vec3 wi, out vec3 wo, out float weight) {
    if (m.type == MATERIAL_INTERFACED) {
        wo = sampleInterfacedMicrosurfacePhaseFunction(m, wi, weight);
        return true;
    } else if (m.type == MATERIAL_METAL) {
        wo = sampleConductorMicrosurfacePhaseFunction(m, wi, weight);
        return true;
    }
    return false;
}

float evalSmoothPhase(material m, vec3 wi, vec3 wo) {
    if (m.type == MATERIAL_INTERFACED) {
        return evalSmoothInterfacedPhaseFunction(m, wi, wo);
    } else {
        return 0.0;
    }
}

bool sampleSmoothPhase(material m, vec3 wi, out vec3 wo, out float weight, out bool dirac) {
    if (m.type == MATERIAL_INTERFACED) {
        wo = sampleSmoothInterfacedPhaseFunction(m, wi, weight, dirac);
        return true;
    } else if (m.type == MATERIAL_METAL) {
        wo = sampleSmoothConductorPhaseFunction(m, wi, weight);
        dirac = true;
        return true;
    }
    return false;
}

float evalSmoothPhasePDF(material m, vec3 wi, vec3 wo) {
    return wo.z / PI;
}

#endif // _MICROSURFACE_PHASE_GLSL