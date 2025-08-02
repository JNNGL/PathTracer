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

#ifndef _MATERIAL_GLSL
#define _MATERIAL_GLSL 1

#include "/lib/buffer/metals.glsl"
#include "/lib/complex/float.glsl"
#include "/lib/reflection/sellmeier.glsl"
#include "/lib/spectral/blackbody.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/settings.glsl"

#define MATERIAL_INTERFACED 0
#define MATERIAL_METAL      1
#define MATERIAL_GLASS      2
#define MATERIAL_BLACKBODY  3
#define MATERIAL_THINFILM   4

struct material {
    int type;
    float albedo;
    float emission;
    vec2 alpha;
    complexFloat ior;
    vec3 normal;
    float ao;
};

float F0toIOR(float f0, float n0) {
    float r = sqrt(f0);
    return (n0 + r) / max(n0 - r, 1.0e-5);
}

material decodeMaterial(int lambda, vec4 albedo, vec4 specular, vec4 normal) {
    material mat;

    mat.type = MATERIAL_INTERFACED;
    mat.albedo = srgbToReflectanceSpectrum(lambda, albedo.rgb);
    mat.emission = fract(specular.a) * srgbToEmissionSpectrum(lambda, albedo.rgb) * EMISSION_STRENGTH;
    mat.alpha = vec2(pow(1.0 - specular.r, 2.0));
    mat.normal = vec3(0.0, 0.0, 1.0);
    mat.ao = 1.0;

#ifdef ENABLE_TRANSLUCENTS
    if (albedo.a < 1.0) {
        mat.type = MATERIAL_GLASS;
    }
#endif

    float f0;
    if (specular.g > 229.5 / 255.0) {
        int id = int(round(specular.g * 255.0));

        mat.type = MATERIAL_METAL;
        
        if (id < 238) {
            mat.ior = getMeasuredMetalIOR(lambda, id - 230);
        } else if (id == 238) {
            mat.type = MATERIAL_BLACKBODY;
            int temperature = int(round(specular.b * 255.0) * 100.0);
            mat.emission = blackbodyScaled(lambda, temperature);
        } else if (id == 239) {
            mat.type = MATERIAL_THINFILM;
            mat.ior = complexFloat(1.0, 0.0);
            mat.emission = 0.0;
        } else {
            mat.ior = complexFloat(F0toIOR(mat.albedo, 1.0), 0.0);
        }
    } else {
        mat.ior = complexFloat(F0toIOR(specular.g, 1.0), 0.0);
        if (mat.type == MATERIAL_GLASS) {
            mat.ior = complexFloat(sellmeier(SCHOTT_N_BK7, lambda), 0.0);
        }
    }

    if (normal != vec4(0.0)) {
        normal.xy = normal.xy * 2.0 - 1.0;
        mat.normal = vec3(normal.x, normal.y, sqrt(1.0 - dot(normal.xy, normal.xy)));
        mat.ao = normal.b;
    }

    return mat;
}

#endif // _MATERIAL_GLSL