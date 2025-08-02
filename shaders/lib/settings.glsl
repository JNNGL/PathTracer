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

#ifndef _SETTINGS_GLSL
#define _SETTINGS_GLSL 1

const ivec3 VOXEL_VOLUME_SIZE = ivec3(512, 386, 512);
const ivec3 HALF_VOXEL_VOLUME_SIZE = VOXEL_VOLUME_SIZE / 2;

#define SKY_CONTRIBUTION
#define SUN_PATH_TYPE 1 // [0 1]
#define SUN_PATH_ANGLE 30 // [0 5 10 15 20 25 30 35 40 45 50 55 60]
#define LATITUDE_DEGREES 50 // [-89 -88 -87 -86 -85 -84 -83 -82 -81 -80 -79 -78 -77 -76 -75 -74 -73 -72 -71 -70 -69 -68 -67 -66 -65 -64 -63 -62 -61 -60 -59 -58 -57 -56 -55 -54 -53 -52 -51 -50 -49 -48 -47 -46 -45 -44 -43 -42 -41 -40 -39 -38 -37 -36 -35 -34 -33 -32 -31 -30 -29 -28 -27 -26 -25 -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89]
#define LATITUDE_MINUTES 33 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59]
#define LATITUDE_SECONDS 0 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59]
#define LONGITUDE_DEGREES 142 // [-179 -178 -177 -176 -175 -174 -173 -172 -171 -170 -169 -168 -167 -166 -165 -164 -163 -162 -161 -160 -159 -158 -157 -156 -155 -154 -153 -152 -151 -150 -149 -148 -147 -146 -145 -144 -143 -142 -141 -140 -139 -138 -137 -136 -135 -134 -133 -132 -131 -130 -129 -128 -127 -126 -125 -124 -123 -122 -121 -120 -119 -118 -117 -116 -115 -114 -113 -112 -111 -110 -109 -108 -107 -106 -105 -104 -103 -102 -101 -100 -99 -98 -97 -96 -95 -94 -93 -92 -91 -90 -89 -88 -87 -86 -85 -84 -83 -82 -81 -80 -79 -78 -77 -76 -75 -74 -73 -72 -71 -70 -69 -68 -67 -66 -65 -64 -63 -62 -61 -60 -59 -58 -57 -56 -55 -54 -53 -52 -51 -50 -49 -48 -47 -46 -45 -44 -43 -42 -41 -40 -39 -38 -37 -36 -35 -34 -33 -32 -31 -30 -29 -28 -27 -26 -25 -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179]
#define LONGITUDE_MINUTES 36 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59]
#define LONGITUDE_SECONDS 0 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59]
// #define USE_SYSTEM_TIME
#define TIME_ZONE 33 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37]

#define RUSSIAN_ROULETTE
#define BSDF_EVAL_RUSSIAN_ROULETTE
// #define BSDF_SAMPLE_RUSSIAN_ROULETTE

// #define NEIGHBOURHOOD_CLAMPING
#define TONEMAP 3 // [0 1 2 3]

#define LENS_TYPE 2 // [0 1 2 3 4]
#define APERTURE_SHAPE 0 // [0 1]
#define SENSOR_SIZE 100 // [50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200]
#define EXPOSURE 0 // [0 1]
#define ISO 100 // [50 100 200 400 800 1600 3200]
#define SHUTTER_SPEED 125 // [1500 1000 500 250 125 60 30 15 8]
#define EV 0 // [-5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.75 -0.5 -0.25 0 +0.25 +0.5 +0.75 +1 +1.5 +2 +2.5 +3 +3.5 +4 +4.5 +5]
#define F_NUMBER 16 // [0 1 1.4 2 2.8 4 5.6 8 11 16 22 32]

#define VOXEL_OFFSET 0.0

#define DEBUG_INFO 1 // [0 1 2]
#define PRINT_LENS_TYPE
#define PRINT_CAMERA_SETTINGS
#define PRINT_COATING_INFO
#define PRINT_RENDER_TIME
#define PRINT_SAMPLES
#define PRINT_FRAME_TIME
#define PRINT_LOCATION

#define EMISSION_STRENGTH 6.0 // [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0]
#define THIN_FILM_CONFIGURATION 0 // [0 1]
// #define ENABLE_TRANSLUCENTS
#define GLASS_ABSORPTION 3.0 // [0.10 0.25 0.50 0.75 1.0 1.5 2.0 3.0 4.0]

// #define ENABLE_SPHERES

#define QUAD_BUFFER_SIZE 1 // [1 2 3 4]
// #define VOXELIZE_ENTITIES
#define ENTITY_ATLAS_SIZE 4096 // [1024 2048 4096 8192 16384]
#define MAX_ENTITY_TEXTURE_SIZE 256 // [128 256 512 1024]
#define HIDE_NAMEPLATES

const float sunPathRotation = SUN_PATH_ANGLE;

#ifdef VOXELIZE_ENTITIES
/*
const int shadowcolor0Format = RGB32UI;
const bool shadowcolor0Clear = false;
*/

const int shadowMapResolution = ENTITY_ATLAS_SIZE;
#else
const int shadowMapResolution = 512;
#endif

vec2 getGeographicCoordinates() {
    float latitude = float(LATITUDE_DEGREES);
    latitude += float(sign(LATITUDE_DEGREES) * LATITUDE_MINUTES) / 60.0;
    latitude += float(sign(LATITUDE_DEGREES) * LATITUDE_SECONDS) / 3600.0;

    float longitude = float(LONGITUDE_DEGREES);
    longitude += float(sign(LONGITUDE_DEGREES) * LONGITUDE_MINUTES) / 60.0;
    longitude += float(sign(LONGITUDE_DEGREES) * LONGITUDE_SECONDS) / 3600.0;

    return vec2(latitude, longitude);
}

#endif // _SETTINGS_GLSL