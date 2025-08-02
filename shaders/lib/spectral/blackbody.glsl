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

#ifndef _BLACKBODY_GLSL
#define _BLACKBODY_GLSL 1

float blackbody(float l, float T) {
    const float h = 6.62607015e-16;
    const float c = 2.99792458e17;
    const float k = 1.380649e-5;

    return 2.0 * h * c * c / pow(l, 5.0) / (exp((h * c) / (l * k * T)) - 1.0);
}

float blackbodyScaled(int lambda, int T) {
    float p = blackbody(float(lambda), float(T));
    float radiated = 5.670374419e-8 * float(T * T) * float(T * T);
    return 15.0 * p / radiated;
}

#endif // _BLACKBODY_GLSL