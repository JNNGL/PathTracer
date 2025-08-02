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

#ifndef _OCTREE_GLSL
#define _OCTREE_GLSL 1

#include "/lib/settings.glsl"

layout (std430, binding = 5) buffer octree_buffer {
    uint data[];
} octree;

const int[] OCTREE_OFFSETS = int[](0, 12582912, 14155776, 14352384, 14376960, 14380032, 14380416);

int getOctreeBitIndex(ivec3 localPos) {
    return localPos.y * 4 + localPos.z * 2 + localPos.x;
}

int getOctreeIndex(int level, ivec3 lodPos) {
    ivec3 levelSize = VOXEL_VOLUME_SIZE >> (level + 1);
    return OCTREE_OFFSETS[level] + lodPos.y * levelSize.x * levelSize.z + lodPos.z * levelSize.x + lodPos.x;
}

int getOctreeIndex(int level, ivec3 voxelPos, out ivec3 localPos) {
    ivec3 levelSize = VOXEL_VOLUME_SIZE >> (level + 1);
    localPos = voxelPos >> level;
    ivec3 lodPos = localPos >> 1;
    localPos -= lodPos * 2;
    return OCTREE_OFFSETS[level] + lodPos.y * levelSize.x * levelSize.z + lodPos.z * levelSize.x + lodPos.x;
}

void occupyOctreeVoxel(int level, ivec3 voxelPos) {
    ivec3 localPos;
    int index = getOctreeIndex(level, voxelPos, localPos);
    int bitIndex = getOctreeBitIndex(localPos);
    atomicOr(octree.data[index], 1u << uint(bitIndex));
}

void occupyOctreeVoxel(ivec3 voxelPos) {
    occupyOctreeVoxel(0, voxelPos);
    occupyOctreeVoxel(1, voxelPos);
    occupyOctreeVoxel(2, voxelPos);
    occupyOctreeVoxel(3, voxelPos);
    occupyOctreeVoxel(4, voxelPos);
    occupyOctreeVoxel(5, voxelPos);
}

#endif // _OCTREE_GLSL