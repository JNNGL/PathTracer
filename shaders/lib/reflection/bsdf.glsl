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

#ifndef _BSDF_GLSL
#define _BSDF_GLSL 1

#include "/lib/utility/material.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/settings.glsl"

float currentIOR;
float currentMediumAbsorbtance;

#include "/lib/reflection/heitz.glsl"
#include "/lib/reflection/mbnm.glsl"
#include "/lib/reflection/thinfilm.glsl"

struct bsdf_sample {
    vec3 direction;
    float value;
    float pdf;
    bool dirac;
};

void sampleGlassBSDF(material mat, vec3 wi, out vec3 wo) {
    float n0 = 1.0;
    float n1 = mat.ior.x;

    if (currentIOR != 1.0) {
        n0 = currentIOR;
        n1 = 1.0;
    }

    if (random1() < fresnelDielectric(wi.z, n0, n1)) {
        wo = vec3(-wi.xy, wi.z);
    } else {
        wo = refract(-wi, vec3(0.0, 0.0, 1.0), n0 / n1);
        if (currentIOR == 1.0) {
            currentIOR = n1;
            currentMediumAbsorbtance = (1.0 - mat.albedo) * GLASS_ABSORPTION;
        } else {
            currentIOR = 1.0;
            currentMediumAbsorbtance = 0.0;
        }
    }
}

float evalMBNMicrofacetBSDF(material m, vec3 wi, vec3 wo) {
    if (m.type == MATERIAL_GLASS) {
        return 0.0;
    }

    if (any(lessThan(m.alpha, vec2(0.001)))) {
        return evalSmoothPhase(m, wi, wo);
    } else {
        return evalMicrosurfaceBSDF(m, wi, wo);
    }
}

bool sampleMBNMicrofacetBSDF(material m, vec3 wi, out vec3 wo, out float weight, out bool dirac) {
    if (m.type == MATERIAL_GLASS) {
        dirac = true;
        weight = 1.0;
        sampleGlassBSDF(m, wi, wo);
        return true;
    }

    if (any(lessThan(m.alpha, vec2(0.001)))) {
        return sampleSmoothPhase(m, wi, wo, weight, dirac);
    } else {
        dirac = false;
        return sampleMicrosurfaceBSDF(m, wi, wo, weight);
    }
}

float evalMBNMicrofacetPDF(material m, vec3 wi, vec3 wo) {
    if (any(lessThan(m.alpha, vec2(0.001)))) {
        return evalSmoothPhasePDF(m, wi, wo);
    } else {
        return evalMicrosurfacePDF(m, wi, wo);
    }
}

float evaluateBSDF(material mat, vec3 wi, vec3 wo, bool dirac) {
    if (mat.type == MATERIAL_BLACKBODY || mat.type == MATERIAL_THINFILM || mat.type == MATERIAL_GLASS) {
        return 0.0;
    }

    return evalMicrosurfaceBSDF_MBN(mat, wi, wo) / abs(wo.z);
}

float evaluateBSDFSamplePDF(material mat, vec3 wi, vec3 wo) {
    if (mat.type == MATERIAL_BLACKBODY || mat.type == MATERIAL_THINFILM || mat.type == MATERIAL_GLASS) {
        return 0.0;
    }

    // Not a valid PDF, but works fine as a MIS weight
    return evalMicrosurfacePDF_MBN(mat, wi, wo);
}

void sampleThinFilmBSDF(inout bsdf_sample bsdfSample, float wavelength, vec3 wi) {
    bsdfSample.dirac = true;

    film_stack stack = beginFilmStack(abs(wi.z), wavelength, complexFloat(1.0, 0.0));
#if (THIN_FILM_CONFIGURATION == 0)
    addThinFilmLayer(stack, complexFloat(1.35, 0.0), 430.0);
#elif (THIN_FILM_CONFIGURATION == 1)
    addThinFilmLayer(stack, getMeasuredMetalIOR(int(wavelength), 1), 10.0);
#endif
    vec2 intensities = endFilmStack(stack, complexFloat(1.0, 0.0));

    float reflectionProbability = intensities.x;
    if (random1() < reflectionProbability) {
        bsdfSample.direction = vec3(-wi.xy, wi.z);
        bsdfSample.pdf = reflectionProbability;
        bsdfSample.value = intensities.x / wi.z;
    } else {
        bsdfSample.direction = -wi;
        bsdfSample.pdf = 1.0 - reflectionProbability;
        bsdfSample.value = intensities.y / wi.z;
    }
}

bool sampleBSDF(inout bsdf_sample bsdfSample, float wavelength, mat3 tbn, material mat, vec3 wi) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return false;
    }

    if (mat.type == MATERIAL_THINFILM) {
        sampleThinFilmBSDF(bsdfSample, wavelength, wi);
        return true;
    }

    float throughput;
    if (!sampleMicrosurfaceBSDF_MBN(mat, wi, bsdfSample.direction, throughput, bsdfSample.dirac)) {
        return false;
    }

    bsdfSample.direction = bsdfSample.direction;
    bsdfSample.pdf = bsdfSample.dirac ? 1.0 : evaluateBSDFSamplePDF(mat, wi, bsdfSample.direction);
    
    bsdfSample.value = bsdfSample.pdf * throughput / abs(bsdfSample.direction.z);

    return true;
}

#endif // _BSDF_GLSL