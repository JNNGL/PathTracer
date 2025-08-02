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

#ifndef _SPECTRAL_SAMPLING_GLSL
#define _SPECTRAL_SAMPLING_GLSL 1

#include "/lib/buffer/spectral.glsl"

int sampleWavelength(float u, out float pdf) {
    float wl = 556.638293609 - 130.023639424 * atanh(0.85691062 - 1.82750197 * u);
    float denom = cosh(4.28105 - 0.00769091 * wl);
    pdf = 0.00420843 / (denom * denom);
    return clamp(int(wl), WL_MIN, WL_MAX);
}

#endif // _SPECTRAL_SAMPLING_GLSL