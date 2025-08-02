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

#ifndef _ATMOSPHERE_CONSTANTS_GLSL
#define _ATMOSPHERE_CONSTANTS_GLSL 1

#include "/lib/utility/constants.glsl"

const float earthRadius = 6371.3e3;
const float atmosphereRadius = 6451.3e3;

const float astronomicalUnit = 149597870700.0;
const float sunRadius = 695700.0e3;

const float atmosphereTurbidity = 3.0;

const float aerosolDiameter = 1.0;

#endif // _ATMOSPHERE_CONSTANTS_GLSL