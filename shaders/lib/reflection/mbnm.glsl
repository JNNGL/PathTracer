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

#ifndef _MBNM_GLSL
#define _MBNM_GLSL 1

// https://jo.dreggn.org/home/2017_normalmap.pdf

float mbnm_projectedArea_p(material m, vec3 wi) {
    return max(0.0, dot(wi, m.normal)) / max(0.0, m.normal.z);
}

float mbnm_projectedArea_t(material m, vec3 wi, vec3 wt) {
    return max(0.0, dot(wi, wt)) * sqrt(1.0 - m.normal.z * m.normal.z) / max(0.0, m.normal.z);
}

float mbnm_lambda_p(material m, vec3 wi, vec3 wt) {
    float ap = mbnm_projectedArea_p(m, wi);
    return ap / (ap + mbnm_projectedArea_t(m, wi, wt));
}

float mbnm_lambda_t(material m, vec3 wi, vec3 wt) {
    float at = mbnm_projectedArea_t(m, wi, wt);
    return at / (at + mbnm_projectedArea_p(m, wi));
}

float mbnm_G1(material m, vec3 wi, vec3 wt, vec3 wm) {
    if (dot(wi, wm) < 0.0) return 0.0;
    return min(1.0, max(0.0, wi.z) / (mbnm_projectedArea_p(m, wi) + mbnm_projectedArea_t(m, wi, wt)));
}

float evalMBNMicrofacetBSDF(material m, vec3 wi, vec3 wo);
bool sampleMBNMicrofacetBSDF(material m, vec3 wi, out vec3 wo, out float weight, out bool dirac);
float evalMBNMicrofacetPDF(material m, vec3 wi, vec3 wo);

float evalMicrosurfaceBSDF_MBN(material m, vec3 wi, vec3 wo) {
    if (abs(m.normal.x) + abs(m.normal.y) < 1.0e-5) {
        return evalMBNMicrofacetBSDF(m, wi, wo);
    }

    vec3 wt = normalize(-vec3(m.normal.xy, 0.0));
    bool wp_first = random1() < mbnm_lambda_p(m, wi, wt);
    vec3 wm = wp_first ? m.normal : wt;
    vec3 wr = -wi;
    
    vec3 b1, b2;
    buildOrthonormalBasis(wt, b1, b2);
    mat3 wtToLocal = mat3(b1, b2, wt);

    buildOrthonormalBasis(m.normal, b1, b2);
    mat3 wpToLocal = mat3(b1, b2, m.normal);

    mat3 wmToLocal = wp_first ? wpToLocal : wtToLocal;

    float sum = 0.0;
    float throughput = 1.0;
    for (int i = 0; i < 256; i++) {
        vec3 wm_wr = wr * wmToLocal;
        vec3 wm_wo = wo * wmToLocal;

        float phase = evalMBNMicrofacetBSDF(m, -wm_wr, wm_wo);
        float shadowing = mbnm_G1(m, wo, wt, wm);
        float I = phase * shadowing;

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

        bool dirac;
        float weight;
        if (!sampleMBNMicrofacetBSDF(m, -wm_wr, wm_wr, weight, dirac)) {
            break;
        }
        wr = wmToLocal * wm_wr;
        throughput *= weight;

        if (random1() < mbnm_G1(m, wr, wt, wm)) {
            break;
        } else {
            wmToLocal = wm == wt ? wpToLocal : wtToLocal;
            wm = wm == wt ? m.normal : wt;
        }
    }

    return sum;
}

bool sampleMicrosurfaceBSDF_MBN(material m, vec3 wi, out vec3 wo, out float throughput, out bool dirac) {
    if (abs(m.normal.x) + abs(m.normal.y) < 1.0e-5) {
        return sampleMBNMicrofacetBSDF(m, wi, wo, throughput, dirac);
    }

    vec3 wt = normalize(-vec3(m.normal.xy, 0.0));
    bool wp_first = random1() < mbnm_lambda_p(m, wi, wt);
    vec3 wm = wp_first ? m.normal : wt;
    vec3 wr = -wi;
    
    vec3 b1, b2;
    buildOrthonormalBasis(wt, b1, b2);
    mat3 wtToLocal = mat3(b1, b2, wt);

    buildOrthonormalBasis(m.normal, b1, b2);
    mat3 wpToLocal = mat3(b1, b2, m.normal);

    mat3 wmToLocal = wp_first ? wpToLocal : wtToLocal;

    throughput = 1.0;
    for (int i = 0; i <= 256; i++) {
        float weight;
        vec3 wm_wr = wr * wmToLocal;
        if (!sampleMBNMicrofacetBSDF(m, -wm_wr, wm_wr, weight, dirac)) {
            break;
        }
        wr = wmToLocal * wm_wr;
        throughput *= weight;

        if (dot(wr, wm) < 0.0 || random1() < mbnm_G1(m, wr, wt, wm)) {
            wo = wr;
            return true;
        } else {
            wmToLocal = wm == wt ? wpToLocal : wtToLocal;
            wm = wm == wt ? m.normal : wt;
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

float evalMicrosurfacePDF_MBN(material m, vec3 wi, vec3 wo) {
    if (abs(m.normal.x) + abs(m.normal.y) < 1.0e-5) {
        return evalMBNMicrofacetPDF(m, wi, wo);
    }

    vec3 wt = normalize(-vec3(m.normal.xy, 0.0));
    float p_wp = mbnm_lambda_p(m, wi, wt);

    float pdf = 0.0;
    if (p_wp > 0.0) {
        vec3 w1, w2;
        buildOrthonormalBasis(m.normal, w1, w2);
        mat3 wpToLocal = mat3(w1, w2, m.normal);
        pdf += p_wp * evalMBNMicrofacetPDF(m, wi * wpToLocal, wo * wpToLocal);
    }
    if (p_wp < 1.0) {
        vec3 w1, w2;
        buildOrthonormalBasis(wt, w1, w2);
        mat3 wtToLocal = mat3(w1, w2, wt);
        pdf += (1.0 - p_wp) * evalMBNMicrofacetPDF(m, wi * wtToLocal, wo * wtToLocal);
    }

    pdf *= mbnm_G1(m, wo, wt, m.normal);
    return pdf + wo.z / PI;
}

#endif // _MBNM_GLSL