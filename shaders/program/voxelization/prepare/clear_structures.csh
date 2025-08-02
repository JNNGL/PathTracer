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

#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/buffer/voxel.glsl"

layout (local_size_x = 64, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(224695, 1, 1);

void main() {
    if (renderState.frame > 1) {
        return;
    }

    for (int i = 0; i < 8; i++) {
        uint index = gl_GlobalInvocationID.x * 8 + i;
        if (index >= 512u * 384u * 512u) break;

        uint x = index % 512u;
        uint y = (index / 512u) % 384u;
        uint z = (index / 512u) / 384u;

        imageStore(voxelBuffer, ivec3(x, y, z), uvec4(0, 0, 0, 0));
    }

    if (gl_GlobalInvocationID.x < 1024) {
        renderState.entityData.hashTable[gl_GlobalInvocationID.x] = -1;
        renderState.entityData.tableLock[gl_GlobalInvocationID.x] = 0u;
    }

    if (gl_GlobalInvocationID.x < 256) {
        renderState.entityData.subdividedCells[gl_GlobalInvocationID.x].index = -1;
    } 

    if (gl_GlobalInvocationID.x >= 14380464) return;
    octree.data[gl_GlobalInvocationID.x] = 0u;
}