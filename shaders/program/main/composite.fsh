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
#include "/lib/camera/exposure.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/debug/debug_text.glsl"
#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/time.glsl"
#include "/lib/settings.glsl"

in vec2 texcoord;

uniform float frameTimeSmooth;
uniform float viewHeight;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 color;

void main() {
    vec2 filmCoord = texcoord * 2.0 - 1.0;
    color = getFilmAverageColor(filmCoord);
#ifdef NEIGHBOURHOOD_CLAMPING
    vec3 maxNeighbour = max(
        max(getFilmAverageColor(filmCoord, ivec2(1, 0)).rgb, getFilmAverageColor(filmCoord, ivec2(-1, 0)).rgb),
        max(getFilmAverageColor(filmCoord, ivec2(0, 1)).rgb, getFilmAverageColor(filmCoord, ivec2(0, -1)).rgb)
    );
    color = min(color, maxNeighbour);
#endif

    color = max(XYZ_TO_sRGB * color, 0.0);

    float ev100 = 0.0;
#if (EXPOSURE == 0)
    ev100 = averageLuminanceToEV100(renderState.avgLuminance);
#elif (EXPOSURE == 1)
    ev100 = cameraSettingsToEV100(float(SHUTTER_SPEED), float(ISO));
#endif
    if (renderState.frame != 0) {
        color *= exposureFromEV100(ev100 - float(EV));
    } else {
        color /= 128.0;
    }

    color = tonemap(color);
    color = linearToSrgb(color);

    ivec2 time = ivec2(currentDate.x, currentYearTime.x);
    renderTextOverlay(color, ivec2(gl_FragCoord.xy) / 2, ivec2(1.0, viewHeight * 0.5 - 1.0), time, frameTimeSmooth);
}