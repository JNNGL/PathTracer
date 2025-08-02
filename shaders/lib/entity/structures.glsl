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

#ifndef _ENTITY_STRUCTURES_GLSL
#define _ENTITY_STRUCTURES_GLSL 1

struct texture_key {
    vec4 textureHash;
    ivec2 resolution;
    int entityId;
};

struct entity_texture {
    int index;
    ivec2 position;
    uint hash;
    texture_key key;
    int next;
};

struct texture_cell {
    ivec2 localPosition;
    int index;
};

struct entity_data {
    uint textureIndex;
    uint cellIndex;
    int hashTable[1024];
    uint tableLock[1024];
    entity_texture textures[4096];
    texture_cell subdividedCells[256];
};

#endif // _ENTITY_STRUCTURES_GLSL