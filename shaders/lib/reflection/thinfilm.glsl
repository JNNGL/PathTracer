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

#ifndef _THINFILM_GLSL
#define _THINFILM_GLSL 1

#include "/lib/complex/mat2.glsl"
#include "/lib/reflection/fresnel.glsl"

float fresnelThinFilmSimple(float cos0, float wl, vec3 n, float thickness) {
    vec2 sin12 = (1.0 - cos0 * cos0) * n[0] * n[0] / vec2(n[1] * n[1], n[2] * n[2]);
    if (sin12.x > 1.0 || sin12.y > 1.0) return 1.0;

    vec2 cos12 = sqrt(1.0 - sin12);

    float rs = fresnelRs(n[1], cos12.x, n[0], cos0) * fresnelRs(n[1], cos12.x, n[2], cos12.y); 
    float rp = fresnelRp(n[1], cos12.x, n[0], cos0) * fresnelRp(n[1], cos12.x, n[2], cos12.y); 
    float ts = fresnelTs(n[0], cos0, n[1], cos12.x) * fresnelTs(n[1], cos12.x, n[2], cos12.y); 
    float tp = fresnelTp(n[0], cos0, n[1], cos12.x) * fresnelTp(n[1], cos12.x, n[2], cos12.y);

    float t = cos(4.0 * PI * thickness * n[1] * cos12.x / wl);
    float Ts = (ts * ts) / pow(1.0 - rs * t, 2.0); 
    float Tp = (tp * tp) / pow(1.0 - rp * t, 2.0); 

    return 1.0 - (n[2] * cos12.y) / (n[0] * cos0) * (Ts + Tp) * 0.5; 
}

complexFloat computeRefractedAngle(complexFloat theta, complexFloat n1, complexFloat n2) {
    return complexArcsin(complexMul(complexSin(theta), complexDiv(n1, n2)));
}

complexMat2 computePropagationMatrix(complexFloat r, complexFloat delta) {
    return complexMat2(
        complexExp(complexMul(complexFloat(0.0, -1.0), delta)), complexMul(r, complexExp(complexMul(complexFloat(0.0, 1.0), delta))),
        complexMul(r, complexExp(complexMul(complexFloat(0.0, -1.0), delta))), complexExp(complexMul(complexFloat(0.0, 1.0), delta))
    );
}

complexFloat computeWavePhaseChange(complexFloat cosTheta, complexFloat n, float l, float wl) {
    return complexMul(complexMul(complexFloat(2.0 * PI * l / wl, 0.0), cosTheta), n);
}

struct film_stack {
    float wavelength;
    complexFloat theta0;
    complexFloat theta1;
    complexFloat n0;
    complexFloat n;
    float thickness;
    complexMat2 MsPolarized;
    complexMat2 MpPolarized;
    complexFloat TsPolarized;
    complexFloat TpPolarized;
    int state;
};

film_stack beginFilmStack(float cosTheta0, float wavelength, complexFloat iorExternal) {
    film_stack stack;
    stack.wavelength = wavelength;
    stack.theta0 = complexFloat(acos(cosTheta0), 0.0);
    stack.theta1 = stack.theta0;
    stack.n0 = iorExternal;
    stack.n = stack.n0;
    stack.state = 0;
    return stack;
}

void addThinFilmLayer(inout film_stack stack, complexFloat n, float thickness) {
    if (stack.state < 0) return; // Total Internal Reflection

    complexFloat theta1 = computeRefractedAngle(stack.theta1, stack.n, n);
    if (complexNorm(complexSin(theta1)) > 1.0) {
        stack.state = -1;
        return;
    }

    complexFloat cosTheta0 = complexCos(stack.theta1);
    complexFloat cosTheta1 = complexCos(theta1);

    complexFloat delta = (stack.state > 0) 
            ? computeWavePhaseChange(cosTheta0, stack.n, stack.thickness, stack.wavelength)
            : complexFloat(0.0, 0.0);

    complexMat2 Mp = computePropagationMatrix(fresnelRp(stack.n, cosTheta0, n, cosTheta1), delta);
    complexMat2 Ms = computePropagationMatrix(fresnelRs(stack.n, cosTheta0, n, cosTheta1), delta);

    complexFloat Tp = fresnelTp(stack.n, cosTheta0, n, cosTheta1);
    complexFloat Ts = fresnelTs(stack.n, cosTheta0, n, cosTheta1);

    if (stack.state == 0) {
        stack.MpPolarized = Mp;
        stack.MsPolarized = Ms;
        stack.TpPolarized = Tp;
        stack.TsPolarized = Ts;
    } else {
        stack.MpPolarized = complexMul(stack.MpPolarized, Mp);
        stack.MsPolarized = complexMul(stack.MsPolarized, Ms);
        stack.TpPolarized = complexMul(stack.TpPolarized, Tp);
        stack.TsPolarized = complexMul(stack.TsPolarized, Ts);
    }

    stack.theta1 = theta1;
    stack.thickness = thickness;
    stack.n = n;
    stack.state = 1;
}

vec2 endFilmStack(inout film_stack stack, complexFloat iorInternal) {
    addThinFilmLayer(stack, iorInternal, 0.0);

    if (stack.state < 0) { // Total Internal Reflection
        return vec2(1.0, 0.0);
    }

    complexFloat cosTheta0 = complexCos(stack.theta0);
    complexFloat cosTheta1 = complexCos(stack.theta1);

    float tp = complexDiv(complexDiv(cosTheta1, iorInternal), complexDiv(cosTheta0, stack.n0)).x *
        complexNorm(complexMul(complexDiv(iorInternal, stack.n0), complexDiv(stack.TpPolarized, stack.MpPolarized.m00)));
    float ts = complexDiv(complexMul(iorInternal, cosTheta1), complexMul(stack.n0, cosTheta0)).x *
        complexNorm(complexDiv(stack.TsPolarized, stack.MsPolarized.m00));

    float rp = complexNorm(complexDiv(stack.MpPolarized.m01, stack.MpPolarized.m00));
    float rs = complexNorm(complexDiv(stack.MsPolarized.m01, stack.MsPolarized.m00));

    float R = clamp(0.5 * (rp + rs), 0.0, 1.0);
    float T = clamp(0.5 * (tp + ts), 0.0, 1.0);

    return vec2(R, T);
}

#endif // _THINFILM_GLSL