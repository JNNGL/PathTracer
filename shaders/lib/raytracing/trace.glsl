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

#ifndef _RAYTRACE_GLSL
#define _RAYTRACE_GLSL 1

#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/voxel.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/intersection.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/constants.glsl"
#include "/lib/utility/intersectors.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/settings.glsl"

// TODO: Rewrite this mess

uniform usampler2D shadowcolor0;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;

float intersectSceneBounds(scene_aabb aabb, ray r) {
    vec3 bMin = (vec3(aabb.xMin, aabb.yMin, aabb.zMin) - r.origin) / r.direction;
    vec3 bMax = (vec3(aabb.xMax, aabb.yMax, aabb.zMax) - r.origin) / r.direction;
    vec3 t1 = min(bMin, bMax);

    return max(max(max(t1.x, t1.y), t1.z) - 0.5, 0.0);
}

void getSceneBounds(scene_aabb aabb, ivec3 voxelOffset, out vec3 minBound, out vec3 maxBound) {
    minBound = vec3(aabb.xMin, aabb.yMin, aabb.zMin) + vec3(voxelOffset) - 1.0;
    maxBound = vec3(aabb.xMax, aabb.yMax, aabb.zMax) + vec3(voxelOffset) + 1.0;
}

float stepVoxel(inout vec3 voxel, inout vec3 origin, vec3 direction, float voxelSize, ivec3 offset) {
    vec3 currentCell = floor(voxel / voxelSize);
    vec3 dist = ((currentCell + max(sign(direction), 0.0)) * voxelSize - origin - vec3(offset)) / direction;
    float t = min(dist.x, min(dist.y, dist.z));

    origin += direction * t;

    vec3 voxelDirection = step(dist, vec3(t)) * sign(direction);
    voxel = vec3(offset) + floor(origin + voxelDirection * 0.5);

    vec3 nextCellMin = (currentCell + voxelDirection) * voxelSize;
    vec3 nextCellMax = nextCellMin + voxelSize;
    voxel = clamp(voxel, nextCellMin, nextCellMax - 1.0);

    return t;
}

bool rayEscapedScene(vec3 voxel, vec3 boundMin, vec3 boundMax) {
    return any(lessThan(voxel, boundMin)) || any(greaterThan(voxel, boundMax));
}

bool intersectModelElement(inout quad_entry entry, ray r, vec3 voxelPos, float tMax, out vec3 normal, out float d, 
                           out float t, out vec4 albedo, inout vec4 normalTex, inout vec4 specularTex) {
#ifdef ENABLE_SPHERES
    if ((entry.tint >> 24u) == 254u) {
        vec2 t2 = intersectSphere(r, voxelPos + 0.5, 0.498);
        if (t2.y < 0.0) {
            return false;
        }

        t = t2.x < 0.0 ? t2.y : t2.x;
        if (t > tMax) {
            return false;
        }

        normal = normalize(r.origin + r.direction * t - voxelPos - 0.5);
        d = dot(normal, r.direction);

        buildOrthonormalBasis(normal, entry.tangent.xyz, entry.bitangent.xyz);
        vec2 unwrap = vec2(atan(-normal.z, normal.x) / (2.0 * PI) + 0.5, acos(-normal.y) / PI);
        vec2 uv = mix(entry.uv0, entry.uv1, unwrap);
        albedo = textureLod(colortex10, uv, 0) * vec4(unpackUnorm4x8(entry.tint).rgb, 1.0);
        normalTex = textureLod(colortex12, uv, 0);
        specularTex = textureLod(colortex11, uv, 0);
        return true;
    }
#endif
    
    normal = cross(entry.tangent.xyz, entry.bitangent.xyz);
    d = dot(normal, r.direction);
    if (abs(d) < 1.0e-6) {
        return false;
    }

    t = (entry.point.w - dot(normal, r.origin)) / d;
    if (t <= 0.0 || t > tMax) {
        return false;
    }

    vec3 point = r.origin + r.direction * t;
    vec3 pLocal = point - voxelPos;
    if (clamp(pLocal, -0.001, 1.001) != pLocal) {
        return false;
    }

    vec3 pTangent = (point - entry.point.xyz) * mat3(entry.tangent.xyz, entry.bitangent.xyz, -normal);
    pTangent.xy /= vec2(entry.tangent.w, entry.bitangent.w);
    if (clamp(pTangent.xy, 0.0, 1.0) != pTangent.xy) {
        return false;
    }

    bool isEntity = (entry.tint >> 24u) == 253u;
    vec2 uv = mix(entry.uv0, entry.uv1, pTangent.xy);
    if (isEntity) {
        albedo = unpackUnorm4x8(texture(shadowcolor0, uv).x);
    } else {
        albedo = textureLod(colortex10, uv, 0);
    }
    albedo *= vec4(unpackUnorm4x8(entry.tint).rgb, 1.0);

    if (albedo.a < 0.1) {
        return false;
    }

    if (isEntity) {
        uvec3 texData = texture(shadowcolor0, uv).xyz;
        normalTex = unpackUnorm4x8(texData.y);
        specularTex = unpackUnorm4x8(texData.z);
    } else {
        normalTex = textureLod(colortex12, uv, 0);
        specularTex = textureLod(colortex11, uv, 0);
    }

    return true;
}

bool intersectsVoxel(ray r, uint pointer, vec3 voxelPos, float tMax) {
    int traversed = 0;
    while (pointer != 0u && traversed < 1024) {
        quad_entry entry = quadBuffer.list[pointer - 1u];

        pointer = entry.next;
        traversed++;

        vec3 normal;
        float d, t;
        vec4 a, n, s;
        if (!intersectModelElement(entry, r, voxelPos, tMax, normal, d, t, a, n, s)) {
            continue;
        }

        return true;
    }

    return false;
}

bool traceShadowRay(ivec3 voxelOffset, ray r, float tMax) {
    scene_aabb aabb = quadBuffer.aabb;

    float t = intersectSceneBounds(aabb, r);
    r.origin += r.direction * t;

    vec3 voxel = floor(r.origin);

    voxelOffset += HALF_VOXEL_VOLUME_SIZE;
    voxel += vec3(voxelOffset);

    vec3 boundMin, boundMax;
    getSceneBounds(aabb, voxelOffset, boundMin, boundMax);

    int octreeLevel = 5;
    for (int i = 0; i < 1024; i++) {
        if (octreeLevel == 0) {
            uint pointer = imageLoad(voxelBuffer, ivec3(voxel)).r;
            if (intersectsVoxel(r, pointer, voxel - vec3(voxelOffset), tMax - t)) {
                return true;
            }
        } else if (octree.data[getOctreeIndex(octreeLevel - 1, ivec3(voxel) >> octreeLevel)] != 0u) {
            octreeLevel--;
            continue;
        }

        if (rayEscapedScene(voxel, boundMin, boundMax)) {
            return false;
        }

        vec3 prevVoxel = voxel;
        float voxelSize = float(1 << octreeLevel);
        
        t += stepVoxel(voxel, r.origin, r.direction, voxelSize, voxelOffset);
        if (t > tMax) {
            return false;
        }

        if (floor(prevVoxel / (voxelSize * 2.0)) != floor(voxel / (voxelSize * 2.0))) {
            octreeLevel = min(octreeLevel + 1, 5);
        }
    }
    
    return false;
}

bool traceVoxel(ray r, uint pointer, vec3 voxelPos, inout intersection it) {
    int traversed = 0;

    bool hasIntersection = false;
    while (pointer != 0u && traversed < 1024) {
        quad_entry entry = quadBuffer.list[pointer - 1u];

        pointer = entry.next;
        traversed++;

        float d, t;
        vec4 albedo;
        vec3 normal;
        if (!intersectModelElement(entry, r, voxelPos, it.t, normal, d, t, albedo, it.normal, it.specular)) {
            continue;
        }

        d = sign(d);

        it.t = t;
        it.tbn = mat3(d * entry.tangent.xyz, d * entry.bitangent.xyz, -d * normal);
        it.albedo = albedo;

        hasIntersection = true;
    }

    return hasIntersection;
}

bool traceRay(inout intersection it, ivec3 voxelOffset, ray r) {
    scene_aabb aabb = quadBuffer.aabb;

    vec3 rayPosition = r.origin;
    rayPosition += r.direction * intersectSceneBounds(aabb, r);

    voxelOffset += HALF_VOXEL_VOLUME_SIZE;
    vec3 voxel = floor(rayPosition) + vec3(voxelOffset);

    vec3 boundMin, boundMax;
    getSceneBounds(aabb, voxelOffset, boundMin, boundMax);

    it.t = 1.0e16;
    int octreeLevel = 5;
    for (int i = 0; i < 1024; i++) {
        if (octreeLevel == 0) {
            uint pointer = imageLoad(voxelBuffer, ivec3(voxel)).r;
            if (traceVoxel(r, pointer, voxel - vec3(voxelOffset), it)) {
                return true;
            }
        } else if (octree.data[getOctreeIndex(octreeLevel - 1, ivec3(voxel) >> octreeLevel)] != 0u) {
            octreeLevel--;
            continue;
        }

        if (rayEscapedScene(voxel, boundMin, boundMax)) {
            return false;
        }

        vec3 prevVoxel = voxel;
        float voxelSize = float(1 << octreeLevel);

        stepVoxel(voxel, rayPosition, r.direction, voxelSize, voxelOffset);

        if (floor(prevVoxel / (voxelSize * 2.0)) != floor(voxel / (voxelSize * 2.0))) {
            octreeLevel = min(octreeLevel + 1, 5);
        }
    }
    
    return false;
}

#endif // _RAYTRACE_GLSL
