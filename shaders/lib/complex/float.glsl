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

#ifndef _COMPLEX_FLOAT_GLSL
#define _COMPLEX_FLOAT_GLSL 1

#include "/lib/utility/constants.glsl"

#define complexFloat vec2

float complexAbs(complexFloat a) {
    return length(a);
}

float complexNorm(complexFloat a) {
    return dot(a, a);
}

complexFloat complexAdd(complexFloat a, complexFloat b) {
    return a + b;
}

complexFloat complexSub(complexFloat a, complexFloat b) {
    return a - b;
}

complexFloat complexMul(complexFloat a, complexFloat b) {
    return complexFloat(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

complexFloat complexDiv(complexFloat a, complexFloat b) {
    return complexFloat(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / complexNorm(b);
}

complexFloat complexSqrt(complexFloat a) {
    float n = complexAbs(a);
    float t1 = sqrt(0.5 * (n + abs(a.x)));
    float t2 = 0.5 * a.y / t1;

    if (n == 0.0) {
        return complexFloat(0.0, 0.0);
    } else if (a.x >= 0.0) {
        return complexFloat(t1, t2);
    } else {
        return complexFloat(abs(t2), sign(a.y) * t1);
    }
}

complexFloat complexExp(complexFloat a) {
    return complexMul(complexFloat(exp(a.x), 0.0), complexFloat(cos(a.y), sin(a.y)));
}

complexFloat complexSin(complexFloat a) {
    complexFloat e1 = complexExp(complexFloat(a.y, -a.x));
    complexFloat e2 = complexExp(complexFloat(-a.y, a.x));
    return complexMul(complexFloat(0.0, 0.5), complexSub(e1, e2));
}

complexFloat complexCos(complexFloat a) {
    complexFloat e1 = complexExp(complexFloat(-a.y, a.x));
    complexFloat e2 = complexExp(complexFloat(a.y, -a.x));
    return complexMul(complexFloat(0.5, 0.0), complexAdd(e1, e2));
}

float complexArg(complexFloat a) {
    return atan(a.y, a.x);
}

complexFloat complexLog(complexFloat a) {
    return complexFloat(log(complexAbs(a)), complexArg(a));
}

complexFloat complexArcsin(complexFloat a) {
    complexFloat b = complexMul(complexFloat(0.0, 1.0), a);
    complexFloat c = complexSqrt(complexSub(complexFloat(1.0, 0.0), complexMul(a, a)));
    return complexMul(complexFloat(0.0, -1.0), complexLog(complexAdd(b, c)));
}

complexFloat complexArccos(complexFloat a) {
    return complexSub(complexFloat(PI / 2.0, 0.0), complexArcsin(a));
}

#endif // _COMPLEX_FLOAT_GLSL