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

#include "/lib/buffer/state.glsl"
#include "/lib/lens/focusing.glsl"
#include "/lib/lens/pupil.glsl"
#include "/lib/settings.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    float zFront = 0.0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        if (LENS_ELEMENTS[i].curvature == 0.0) {
            renderState.apertureRadius = LENS_ELEMENTS[i].aperture;
        }
        zFront += LENS_ELEMENTS[i].thickness;
    }
    renderState.lensFrontZ = zFront;

    mat2 transferMatrix = computeRayTransferMatrix(550);
    renderState.rayTransferMatrix = transferMatrix;

    renderState.focalLength = computeFocalLength(transferMatrix);

#if (F_NUMBER != 0)
    float entrancePupilDiameter = renderState.focalLength / float(F_NUMBER);
    renderState.apertureRadius = searchApertureRadius(128, 0.5 * entrancePupilDiameter);
#endif

    renderState.entrancePupilRadius = searchEntrancePupilRadius(128);
    renderState.fNumber = renderState.focalLength / (2.0 * renderState.entrancePupilRadius);
}