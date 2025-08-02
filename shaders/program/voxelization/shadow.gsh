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
#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/buffer/voxel.glsl"
#include "/lib/entity/textures.glsl"
#include "/lib/settings.glsl"

layout (triangles) in;
layout (triangle_strip, max_vertices = 4) out;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPositionFract;

uniform int renderStage;
uniform int entityId;
uniform int blockEntityId;
uniform bool firstPersonCamera;

uniform sampler2D gtexture;

in vec3 vPosition[3];
in vec3 vMidOffset[3];
in vec4 vColor[3];
in vec2 vUV[3];

flat out int storeTexture;
flat out ivec2 origin;

const vec2 VERTEX_OFFSETS[] = vec2[](
    vec2(0.0, 0.0), vec2(1.0, 0.0), vec2(0.0, 1.0), vec2(1.0, 1.0)
);

vec4 calculateTextureHash() {
    vec4 hash = vec4(0.0);
    float t = 1.0;

    for (int x = 0; x < 5; x++) {
        for (int y = 0; y < 5; y++) { 
            hash += textureLod(gtexture, vec2(x, y) / 4.0, 999) * t;
            t += 0.61803398874;
        }
    }

    return hash;
}

void main() {
    if (gl_PrimitiveIDIn % 2 != 0 || vColor[0].a == 0.0 || renderState.frame > 1) {
        return;
    }

    quad_entry entry;

    vec2 uvMin = min(vUV[0], vUV[2]);
    vec2 uvMax = max(vUV[0], vUV[2]);

    entry.uv0 = uvMin;
    entry.uv1 = uvMax;

    int uvMinIndex = 3;
    if (uvMin == vUV[0]) {
        uvMinIndex = 0;
    } else if (uvMin == vUV[1]) {
        uvMinIndex = 1;
    } else if (uvMin == vUV[2]) {
        uvMinIndex = 2;
    }
    
    int tangentIndex = 3;
    if (uvMin.y == vUV[0].y && vUV[0].x > uvMin.x) {
        tangentIndex = 0;
    } else if (uvMin.y == vUV[1].y && vUV[1].x > uvMin.x) {
        tangentIndex = 1;
    } else if (uvMin.y == vUV[2].y && vUV[2].x > uvMin.x) {
        tangentIndex = 2;
    }

    int bitangentIndex = 3;
    if (uvMin.x == vUV[0].x && vUV[0].y > uvMin.y) {
        bitangentIndex = 0;
    } else if (uvMin.x == vUV[1].x && vUV[1].y > uvMin.y) { 
        bitangentIndex = 1;
    } else if (uvMin.x == vUV[2].x && vUV[2].y > uvMin.y) {
        bitangentIndex = 2;
    }

    vec4 tintAndFlags = vColor[0];
    storeTexture = 0;

#ifdef VOXELIZE_ENTITIES
    bool isEntityTexture = all(lessThanEqual(textureSize(gtexture, 0), ivec2(MAX_ENTITY_TEXTURE_SIZE)));
    bool isEntity = (renderStage == MC_RENDER_STAGE_ENTITIES);
    bool isBlockEntity = (renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES);
    if (isEntityTexture && (isEntity || isBlockEntity)) {
        int id = isEntity ? entityId : blockEntityId;
        if ((firstPersonCamera && id == 134)) {
            return;
        }

        tintAndFlags.a = 253.0 / 255.0;
        storeTexture = 1;

        texture_key key;
        key.textureHash = calculateTextureHash();
        key.resolution = textureSize(gtexture, 0).xy;
        key.entityId = id;

        if (!getOrAddTexture(key, origin)) {
            return;
        }
    
        vec2 cellSize = vec2(textureSize(gtexture, 0)) / float(ENTITY_ATLAS_SIZE);
        vec2 lowerLeft = vec2(origin) / float(ENTITY_ATLAS_SIZE);

        entry.uv0 = lowerLeft + entry.uv0 * cellSize;
        entry.uv1 = lowerLeft + entry.uv1 * cellSize;

        for (int i = 0; i < 4; i++) {
            vec2 vertexPosition = lowerLeft + cellSize * VERTEX_OFFSETS[i];
            gl_Position = vec4(vertexPosition * 2.0 - 1.0, 0.0, 1.0);
            EmitVertex();
        }
    }
#endif

    entry.tint = packUnorm4x8(tintAndFlags);

    mat4x3 positionMatrix = mat4x3(vPosition[0], vPosition[1], vPosition[2], vPosition[2] - vPosition[1] + vPosition[0]);
    
    entry.point.xyz = positionMatrix[uvMinIndex] + cameraPositionFract;
    entry.tangent.xyz = positionMatrix[tangentIndex] - positionMatrix[uvMinIndex];
    entry.bitangent.xyz = positionMatrix[bitangentIndex] - positionMatrix[uvMinIndex];
    
    entry.tangent.w = length(entry.tangent.xyz);
    entry.tangent.xyz /= entry.tangent.w;
    entry.bitangent.w = length(entry.bitangent.xyz);
    entry.bitangent.xyz /= entry.bitangent.w;

    vec3 normal = cross(entry.tangent.xyz, entry.bitangent.xyz);
    entry.point.w = dot(normal, entry.point.xyz);

    vec3 minBound = min(min(positionMatrix[0], positionMatrix[1]), min(positionMatrix[2], positionMatrix[3])) + cameraPositionFract;
    vec3 maxBound = max(max(positionMatrix[0], positionMatrix[1]), max(positionMatrix[2], positionMatrix[3])) + cameraPositionFract;

    vec3 normalOffset = normal * 1.0e-4;
    minBound = min(minBound - normalOffset, minBound + normalOffset);
    maxBound = max(maxBound - normalOffset, maxBound + normalOffset);

    ivec3 voxelOffset = ivec3(gbufferModelViewInverse[2].xyz * VOXEL_OFFSET);
    ivec3 voxelMin = ivec3(floor(minBound));
    ivec3 voxelMax = ivec3(ceil(maxBound));

    int blocksOccupied = 0;
    for (int x = voxelMin.x; x < voxelMax.x; x++) {
        for (int y = voxelMin.y; y < voxelMax.y; y++) {
            for (int z = voxelMin.z; z < voxelMax.z; z++) {
                ivec3 voxelPos = ivec3(x, y, z) + HALF_VOXEL_VOLUME_SIZE + voxelOffset;
                if (clamp(voxelPos, ivec3(0, 0, 0), VOXEL_VOLUME_SIZE - 1) != voxelPos) continue;

                uint index = atomicAdd(quadBuffer.count, 1u);
                entry.next = imageAtomicExchange(voxelBuffer, voxelPos, index + 1u);

                quadBuffer.list[index] = entry;

                occupyOctreeVoxel(voxelPos);
                blocksOccupied++;
            }
        }
    }

    if (blocksOccupied > 0) {
        extendSceneBounds(minBound, maxBound);
    }
}