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

#ifndef _CAMERA_RESPONSE_GLSL
#define _CAMERA_RESPONSE_GLSL 1

struct camera_response_entry {
    vec2 channels[3];
};

layout (std430, binding = 6) readonly buffer camera_response {
    camera_response_entry entries[];
} cameraResponse;

float binarySearchCameraResponse(int channel, float irradiance) {
    if (cameraResponse.entries[0].channels[channel].x >= irradiance) {
        return cameraResponse.entries[0].channels[channel].y;
    }
    if (cameraResponse.entries[1023].channels[channel].x <= irradiance) {
        return cameraResponse.entries[1023].channels[channel].y;
    }

    int low = 0;
    int high = 1023;

    while (low <= high) {
        int mid = (low + high) / 2;
        vec2 entry = cameraResponse.entries[mid].channels[channel];
        if (entry.x == irradiance) {
            return entry.y;
        } else if (entry.x < irradiance) {
            vec2 next = cameraResponse.entries[mid + 1].channels[channel];
            if (next.x > irradiance) {
                float t = (irradiance - entry.x) / (next.x - entry.x);
                return mix(entry.y, next.y, t);
            }
            low = mid + 1;
        } else if (entry.x > irradiance) {
            vec2 prev = cameraResponse.entries[mid - 1].channels[channel];
            if (prev.x < irradiance) {
                float t = (irradiance - prev.x) / (entry.x - prev.x);
                return mix(prev.y, entry.y, t);
            }
            high = mid - 1;
        }
    }

    return cameraResponse.entries[low].channels[channel].y;
}

#endif // _CAMERA_RESPONSE_GLSL