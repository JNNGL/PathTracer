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

#ifndef _ENTITY_TEXTURES_GLSL
#define _ENTITY_TEXTURES_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/settings.glsl"

uint hashTextureKey(texture_key key) {
    uint result = uint(key.resolution.x);
    result = 31u * result + uint(key.resolution.y);
    result = 31u * result + floatBitsToUint(key.textureHash.x);
    result = 31u * result + floatBitsToUint(key.textureHash.y);
    result = 31u * result + floatBitsToUint(key.textureHash.z);
    result = 31u * result + floatBitsToUint(key.textureHash.w);
    result = 31u * result + floatBitsToUint(key.entityId);
    return result;
}

ivec3 searchEntityTextureUnsafe(entity_texture handle, uint bucket) {
    int index = renderState.entityData.hashTable[bucket];
    while (index >= 0) {
        entity_texture candidate = renderState.entityData.textures[index];
        if (candidate.hash == handle.hash && candidate.key == handle.key) {
            return ivec3(candidate.index, candidate.position);
        }

        index = candidate.next;
    }

    return ivec3(-1, 0, 0);
}

void addTextureUnsafe(inout entity_texture handle, uint bucket) {
    handle.index = int(atomicAdd(renderState.entityData.textureIndex, 1u));

    const int cellsPerRow = ENTITY_ATLAS_SIZE / MAX_ENTITY_TEXTURE_SIZE;

    if (all(greaterThan(handle.key.resolution, ivec2(MAX_ENTITY_TEXTURE_SIZE / 2)))) {
        int cellIndex = int(atomicAdd(renderState.entityData.cellIndex, 1u));
        handle.position = ivec2(cellIndex % cellsPerRow, cellIndex / cellsPerRow) * MAX_ENTITY_TEXTURE_SIZE;
    } else {
        uvec2 log2TextureSize = uvec2(ceil(log2(vec2(handle.key.resolution))));
        uvec2 pow2TextureSize = uvec2(1u) << log2TextureSize;

        const uint log2MaxSize = 16;//uint(ceil(log2(float(MAX_ENTITY_TEXTURE_SIZE))));
        uint index = log2TextureSize.x + log2MaxSize * log2TextureSize.y;

        texture_cell cell;
        if (renderState.entityData.subdividedCells[index].index == -1) {
            cell.index = int(atomicAdd(renderState.entityData.cellIndex, 1u));
            cell.localPosition = ivec2(0, 0);
        } else {
            cell = renderState.entityData.subdividedCells[index];
        }

        handle.position = ivec2(cell.index % cellsPerRow, cell.index / cellsPerRow) * MAX_ENTITY_TEXTURE_SIZE + cell.localPosition;

        cell.localPosition.x += int(pow2TextureSize.x);
        if (cell.localPosition.x >= MAX_ENTITY_TEXTURE_SIZE) {
            cell.localPosition.x = 0;
            cell.localPosition.y += int(pow2TextureSize.y);
            if (cell.localPosition.y >= MAX_ENTITY_TEXTURE_SIZE) {
                cell.index = -1;
            }
        }

        renderState.entityData.subdividedCells[index] = cell;
    }

    handle.next = renderState.entityData.hashTable[bucket];
    renderState.entityData.textures[handle.index] = handle;
    renderState.entityData.hashTable[bucket] = handle.index;
}

void getOrAddTextureUnsafe(inout entity_texture handle, uint bucket) {
    ivec3 searchResult = searchEntityTextureUnsafe(handle, bucket);
    if (searchResult.x >= 0) {
        handle.index = searchResult.x;
        handle.position = searchResult.yz;
    } else {
        addTextureUnsafe(handle, bucket);
    }
}

bool getOrAddTexture(texture_key key, out ivec2 position) {
    entity_texture handle;
    handle.index = -1;
    handle.hash = hashTextureKey(key);
    handle.key = key;
    handle.next = -1;

    uint bucket = handle.hash & 1023u;
    for (int i = 0; i < 8192; i++) {
        if (atomicCompSwap(renderState.entityData.tableLock[bucket], 0u, 1u) == 0u) {
            getOrAddTextureUnsafe(handle, bucket);
            atomicExchange(renderState.entityData.tableLock[bucket], 0u);

            position = handle.position;
            return handle.index >= 0;
        }
    }

    ivec3 value = searchEntityTextureUnsafe(handle, bucket);

    position = value.yz;
    return value.x >= 0;
}

#endif // _ENTITY_TEXTURES_GLSL