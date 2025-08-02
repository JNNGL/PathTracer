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
#include "/lib/raytracing/trace.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    if (renderState.frame != 0) {
        return;
    }

    vec3 direction = normalize(-renderState.viewMatrixInverse[2].xyz);
    ivec3 voxelOffset = ivec3(renderState.viewMatrixInverse[2].xyz * VOXEL_OFFSET);
    
    intersection it;
    if (traceRay(it, voxelOffset, ray(renderState.cameraPosition, direction))) {
        renderState.focusDistance = it.t;
    } else {
        renderState.focusDistance = 1024.0;
    }

    renderState.rearThicknessDelta = 0.0;
    float zFront = frontLensElementZ();

    mat2 transferMatrix = renderState.rayTransferMatrix;

    const int focusIterations = 4;
    for (int i = 0; i < focusIterations; i++) {
        float focusDistance = renderState.focusDistance + zFront - renderState.rearThicknessDelta;
        float rearThickness = focusLensSystem(transferMatrix, max(focusDistance, 0.0));
        renderState.rearThicknessDelta = max(0.0, rearThickness) - rearLensElement().thickness;
    }
}