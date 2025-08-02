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

#ifndef _FOCUSING_GLSL
#define _FOCUSING_GLSL 1

#include "/lib/lens/configuration.glsl"

mat2 computeRayTransferMatrix(const int wavelength) {
    mat2 transferMatrix = mat2(1.0);
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        lens_element element = LENS_ELEMENTS[i];

        mat2 propagationTransfer = mat2(1.0, 0.0, element.thickness, 1.0);
        if (element.curvature == 0.0) {
            transferMatrix = propagationTransfer * transferMatrix;
            continue;
        }

        float currentEta = i == 0 ? 1.0 : sellmeier(LENS_ELEMENTS[i - 1].glass, wavelength);
        float transmittedEta = sellmeier(element.glass, wavelength);

        mat2 refractionTransfer = mat2(1.0, (currentEta - transmittedEta) / (element.curvature * transmittedEta), 0.0, currentEta / transmittedEta);
        transferMatrix = refractionTransfer * transferMatrix;
        if (i != LENS_ELEMENTS.length() - 1) {
            transferMatrix = propagationTransfer * transferMatrix;
        }
    }

    return transferMatrix;
}

float computeFocalLength(mat2 transferMatrix) {
    const float x = 0.001;

    vec2 r = transferMatrix * vec2(x, 0.0);
    return -x / tan(r.y);
}

float focusLensSystem(mat2 transferMatrix, float focusDistance) {
    const float x = 0.001;

    vec2 r = transferMatrix * vec2(x, atan(x, focusDistance));
    return -r.x / tan(r.y);
}

#endif // _FOCUSING_GLSL