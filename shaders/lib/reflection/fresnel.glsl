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

#ifndef _FRESNEL_GLSL
#define _FRESNEL_GLSL 1

#include "/lib/complex/float.glsl"
#include "/lib/utility/constants.glsl"

float fresnelRs(float n0, float cos0, float n1, float cos1) {
    return (n0 * cos0 - n1 * cos1) / (n0 * cos0 + n1 * cos1);
}

float fresnelRp(float n0, float cos0, float n1, float cos1) {
    return (n0 * cos1 - n1 * cos0) / (n0 * cos1 + n1 * cos0);
}

float fresnelTs(float n0, float cos0, float n1, float cos1) {
    return 2.0 * n0 * cos0 / (n0 * cos0 + n1 * cos1);
}

float fresnelTp(float n0, float cos0, float n1, float cos1) {
    return 2.0 * n0 * cos0 / (n0 * cos1 + n1 * cos0);
}

complexFloat fresnelRs(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexSub(complexMul(n0, cos0), complexMul(n1, cos1)), complexAdd(complexMul(n0, cos0), complexMul(n1, cos1)));
}

complexFloat fresnelRp(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexSub(complexMul(n0, cos1), complexMul(n1, cos0)), complexAdd(complexMul(n0, cos1), complexMul(n1, cos0)));
}

complexFloat fresnelTs(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexMul(complexMul(complexFloat(2.0, 0.0), n0), cos0), complexAdd(complexMul(n0, cos0), complexMul(n1, cos1)));
}

complexFloat fresnelTp(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexMul(complexMul(complexFloat(2.0, 0.0), n0), cos0), complexAdd(complexMul(n0, cos1), complexMul(n1, cos0)));
}

float fresnelDielectric(float cosTheta0, float n0, float n1) {
    float sin2Theta0 = 1.0 - cosTheta0 * cosTheta0;
    float sin2Theta1 = sin2Theta0 * (n0 * n0) / (n1 * n1);
    if (sin2Theta1 >= 1.0) return 1.0;

    float cosTheta1 = sqrt(1.0 - sin2Theta1);

    float rs = fresnelRs(n0, cosTheta0, n1, cosTheta1);
    float rp = fresnelRp(n0, cosTheta0, n1, cosTheta1);

    return 0.5 * (rs * rs + rp * rp);
}

float fresnelOverHemisphere(float n) {
    bool t = (n < 1.0);
    if (t) n = 1.0 / n;
    
    if (n - 1.0 < 1.0e-3) {
        return 0.0;
    }

    float n2 = n * n;
    float n3 = n2 * n;

    float n_1 = (n - 1.0) * (3.0 * n + 1.0);
    float d_1 = 6.0 * (n + 1.0) * (n + 1.0);
    float n_2 = n2 * (n2 - 1.0) * (n2 - 1.0);
    float d_2 = (n2 + 1.0) * (n2 + 1.0) * (n2 + 1.0);
    float n_3 = 2.0 * n3 * (n2 + 2.0 * n - 1.0);
    float d_3 = (n2 + 1.0) * (n2 * n2 - 1.0);
    float n_4 = 8.0 * n2 * n2 * (n2 * n2 + 1.0);
    float d_4 = (n2 + 1.0) * (n2 * n2 - 1.0) * (n2 * n2 - 1.0);
    float Fr = clamp(0.5 + n_1 / d_1 + log((n - 1.0) / (n + 1.0)) * n_2 / d_2 - n_3 / d_3 + log(n) * n_4 / d_4, 0.0, 1.0);
    return t ? (1.0 - (1.0 - Fr) / (n * n)) : Fr;
}

float fresnelConductor(float cosTheta0, complexFloat n0, complexFloat n1) {
    complexFloat sin2Theta0 = complexFloat(1.0 - cosTheta0 * cosTheta0, 0.0);
    complexFloat sin2Theta1 = complexMul(sin2Theta0, complexDiv(complexMul(n0, n0), complexMul(n1, n1)));
    complexFloat cosTheta1 = complexSqrt(complexSub(complexFloat(1.0, 0.0), sin2Theta1));

    complexFloat rp = fresnelRp(complexFloat(cosTheta0, 0.0), n0, cosTheta1, n1);
    complexFloat rs = fresnelRs(complexFloat(cosTheta0, 0.0), n0, cosTheta1, n1);

    return 0.5 * (complexNorm(rp) + complexNorm(rs));
}

#endif // _FRESNEL_GLSL