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

#include "/lib/atmosphere/sun.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform bool hideGUI;

uniform vec3 sunPosition;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPositionFract;
uniform float eyeAltitude;

uniform int worldTime;

void main() {
    if (hideGUI) {
        renderState.frame++;
    } else {
        renderState.frame = 0;
        renderState.invalidSplat = 0;
        renderState.startTime = ivec2(currentDate.x, currentYearTime.x);
        renderState.localTime = currentLocalTime();
#ifndef USE_SYSTEM_TIME
        datetime time2 = renderState.localTime;
        
        time2.hour = 6;
        time2.minute = 0;
        time2.second = 0;

        time2 = unixToDatetime(datetimeToUnix(time2) + uint(float(worldTime) * 3.6));

        renderState.localTime.hour = time2.hour;
        renderState.localTime.minute = time2.minute;
        renderState.localTime.second = time2.second;
#endif
#if (SUN_PATH_TYPE == 1)
        datetime utcTime = convertToUniversalTime(renderState.localTime);
        renderState.sunPosition = getRealisticSunPosition(utcTime, getGeographicCoordinates());
#else
        renderState.sunPosition = getMinecraftSunPosition(mat3(gbufferModelViewInverse) * sunPosition);
#endif
        renderState.sunDirection = normalize(renderState.sunPosition);
    }

    renderState.clear = (renderState.frame <= 1);

    if (renderState.frame <= 1) {
        quadBuffer.aabb = scene_aabb(10000, 10000, 10000, -10000, -10000, -10000);
        quadBuffer.count = 0u;

        renderState.entityData.textureIndex = 0u;
        renderState.entityData.cellIndex = 0u;

        renderState.projection = gbufferProjection;
        renderState.projectionInverse = gbufferProjectionInverse;
        renderState.viewMatrix = gbufferModelView;
        renderState.viewMatrixInverse = gbufferModelViewInverse;
        renderState.cameraPosition = cameraPositionFract;
        renderState.altitude = eyeAltitude;
    }
}