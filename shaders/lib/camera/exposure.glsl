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

#ifndef _EXPOSURE_GLSL
#define _EXPOSURE_GLSL 1

const float logLumMin = -5.0;
const float logLumMax = 5.0;
const float logLumRange = logLumMax - logLumMin;

float toLogLuminance(float lum) {
    return clamp((log2(lum) - logLumMin) / logLumRange, 0.0, 1.0);
}

float fromLogLuminance(float logLum) {
    return exp2(logLum * logLumRange + logLumMin);
}

float averageLuminanceToEV100(float avgLum) {
    return log2(avgLum * 100.0 / 12.5);
}

float cameraSettingsToEV100(float shutterSpeed, float iso) {
    return log2(shutterSpeed * 100.0 / iso);
}

float exposureFromEV100(float ev100) {
    return 1.0 / (1.2 * exp2(ev100));
}

#endif // _EXPOSURE_GLSL