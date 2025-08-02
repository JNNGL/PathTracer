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

#ifndef _COMPLEX_MAT2_GLSL
#define _COMPLEX_MAT2_GLSL 1

#include "/lib/complex/float.glsl"

struct complexMat2 {
    complexFloat m00, m01;
    complexFloat m10, m11;
};

complexMat2 complexMul(complexMat2 x, complexMat2 y) {
    return complexMat2(
        complexAdd(complexMul(x.m00, y.m00), complexMul(x.m10, y.m01)), complexAdd(complexMul(x.m01, y.m00), complexMul(x.m11, y.m01)),
        complexAdd(complexMul(x.m00, y.m10), complexMul(x.m10, y.m11)), complexAdd(complexMul(x.m01, y.m10), complexMul(x.m11, y.m11))
    );
}

#endif // _COMPLEX_MAT2_GLSL