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

#ifndef _APERTURE_GLSL
#define _APERTURE_GLSL 1

#include "/lib/utility/constants.glsl"
#include "/lib/settings.glsl"

bool insideHexagonalAperture(vec2 p, float radius, float rotation) {
    p /= radius;

    float sinTheta = sin(rotation);
    float cosTheta = cos(rotation);
    p = mat2(cosTheta, -sinTheta, sinTheta, cosTheta) * p;

    // https://stackoverflow.com/a/20117209
    float lengthSquared = dot(p, p);
    if (lengthSquared > 1.0) {
        return false;
    }
    if (lengthSquared < 0.75) {
        return true;
    }
    
    float px = p.x * 2.0 / sqrt(3.0);
    if (px > 1.0 || px < -1.0) {
        return false;
    }

    float py = 0.5 * px + p.y;
    if (py > 1.0 || py < -1.0) {
        return false;
    }

    return !(px - py > 1.0 || px - py < -1.0);
}

bool insideCircularAperture(vec2 p, float radius) {
    return dot(p, p) < radius * radius;
}

bool insideAperture(vec2 p, float aperture) {
#if (APERTURE_SHAPE == 0)
    return insideCircularAperture(p, aperture);
#elif (APERTURE_SHAPE == 1)
    return insideHexagonalAperture(p, aperture, -0.3 / PI);
#endif
}

#endif // _APERTURE_GLSL