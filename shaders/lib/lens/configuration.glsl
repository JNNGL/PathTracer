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

#ifndef _CAMERA_CONFIGURATION_GLSL
#define _CAMERA_CONFIGURATION_GLSL 1

#include "/lib/lens/common.glsl"
#include "/lib/settings.glsl"

#if (LENS_TYPE == 0)

// Double Gauss
const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element( 58.950  * 0.001, 7.520  * 0.001, N_BAF10, 50.4 * 0.0005, true),
    lens_element( 169.660 * 0.001, 0.240  * 0.001, AIR    , 50.4 * 0.0005, true),
    lens_element( 38.550  * 0.001, 8.050  * 0.001, N_BAF10, 46.0 * 0.0005, true),
    lens_element( 81.540  * 0.001, 6.550  * 0.001, N_BAF4 , 46.0 * 0.0005, true),
    lens_element( 25.500  * 0.001, 11.410 * 0.001, AIR    , 36.0 * 0.0005, true),
    lens_element( 0.0     * 0.001, 9.0    * 0.001, AIR    , 20.2 * 0.0005, true),
    lens_element(-28.990  * 0.001, 2.360  * 0.001, F5     , 34.0 * 0.0005, true),
    lens_element( 81.540  * 0.001, 12.130 * 0.001, N_SSK5 , 40.0 * 0.0005, true),
    lens_element(-40.770  * 0.001, 0.380  * 0.001, AIR    , 40.0 * 0.0005, true),
    lens_element( 874.130 * 0.001, 6.440  * 0.001, SF1    , 40.0 * 0.0005, true),
    lens_element(-79.460  * 0.001, 0.0    * 0.001, AIR    , 40.0 * 0.0005, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(40.0);

#elif (LENS_TYPE == 1)

// Fisheye
const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element( 302.249 * 0.001, 8.335    * 0.001, N_F2        , 303.4 * 0.0005, true),
    lens_element( 113.931 * 0.001, 74.136   * 0.001, AIR         , 206.8 * 0.0005, true),
    lens_element( 752.019 * 0.001, 10.654   * 0.001, N_LAK21     , 178.0 * 0.0005, true),
    lens_element( 83.349  * 0.001, 111.549  * 0.001, AIR         , 134.2 * 0.0005, true),
    lens_element( 95.882  * 0.001, 20.054   * 0.001, N_SSK5      , 90.2  * 0.0005, true),
    lens_element( 438.677 * 0.001, 53.895   * 0.001, AIR         , 81.4  * 0.0005, true),
    lens_element( 0.0     * 0.001, 14.163   * 0.001, AIR         , 60.8  * 0.0005, true),
    lens_element( 294.541 * 0.001, 21.934   * 0.001, SCHOTT_N_BK7, 59.6  * 0.0005, true),
    lens_element(-52.265  * 0.001, 9.714    * 0.001, SF6         , 58.4  * 0.0005, true),
    lens_element(-142.884 * 0.001, 0.627    * 0.001, AIR         , 59.6  * 0.0005, true),
    lens_element(-223.726 * 0.001, 9.400    * 0.001, N_KZFS11    , 59.6  * 0.0005, true),
    lens_element(-150.404 * 0.001, 0.0      * 0.001, AIR         , 65.2  * 0.0005, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(140.0);

#elif (LENS_TYPE == 2)

// Tessar
const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element(42.970   * 0.001, 9.8    * 0.001, N_LAK9, 19.2 * 0.001, true),
    lens_element(-115.33  * 0.001, 2.1    * 0.001, LLF1  , 19.2 * 0.001, true),
    lens_element( 306.840 * 0.001, 4.16   * 0.001, AIR   , 19.2 * 0.001, true),
    lens_element( 0.0     * 0.001, 4.0    * 0.001, AIR   , 15.0 * 0.001, true),
    lens_element(-59.060  * 0.001, 1.870  * 0.001, SF2   , 17.3 * 0.001, true),
    lens_element( 40.930  * 0.001, 10.640 * 0.001, AIR   , 17.3 * 0.001, true),
    lens_element( 183.920 * 0.001, 7.050  * 0.001, N_LAK9, 16.5 * 0.001, true),
    lens_element(-48.910  * 0.001, 0.0    * 0.001, AIR   , 16.5 * 0.001, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(45.0);

#elif (LENS_TYPE == 3)

// Zeiss Biotar
const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element(  0.836, 0.1075, N_LAK21, 0.36, true),
    lens_element(  3.210, 0.0165, AIR    , 0.36, true),
    lens_element(  0.448, 0.1555, N_SSK2 , 0.32, true),
    lens_element(-11.500, 0.0505, N_BAK1 , 0.32, true),
    lens_element(  0.283, 0.1890, AIR    , 0.22, true),
    lens_element( -0.385, 0.0505, N_SF5  , 0.22, true),
    lens_element(  0.505, 0.2122, N_LAK21, 0.29, true),
    lens_element( -0.532, 0.0097, AIR    , 0.29, true),
    lens_element(  1.060, 0.1390, N_LAK21, 0.29, true),
    lens_element( -1.200, 0.0000, AIR    , 0.29, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(410.0);

#elif (LENS_TYPE == 4)

// Petzval
const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element( 55.9  * 0.001, 5.2  * 0.001, N_BK7HT, 16.0 * 0.001, true),
    lens_element(-43.7  * 0.001, 0.8  * 0.001, LF7    , 16.0 * 0.001, true),
    lens_element( 460.4 * 0.001, 33.6 * 0.001, AIR    , 16.0 * 0.001, true),
    lens_element( 110.6 * 0.001, 1.5  * 0.001, LF7    , 16.0 * 0.001, true),
    lens_element( 38.9  * 0.001, 3.3  * 0.001, AIR    , 16.0 * 0.001, true),
    lens_element( 48.0  * 0.001, 3.6  * 0.001, N_BK7HT, 16.0 * 0.001, true),
    lens_element(-157.8 * 0.001, 30.0 * 0.001, AIR    , 16.0 * 0.001, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(35.0);

#elif (LENS_TYPE == 5)

// Hypergon
const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element( 8.570 * 0.001, 2.212 * 0.001, K7 , 8.2 * 0.001, true),
    lens_element( 8.630 * 0.001, 6.894 * 0.001, AIR, 8.2 * 0.001, true),
    lens_element( 0.0   * 0.001, 6.894 * 0.001, AIR, 1.6 * 0.001, true),
    lens_element(-8.630 * 0.001, 2.212 * 0.001, K7 , 8.2 * 0.001, true),
    lens_element(-8.570 * 0.001, 0.000 * 0.001, AIR, 8.2 * 0.001, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(100.0);

#elif (LENS_TYPE == 6)

// Concentric lens
const lens_element LENS_ELEMENTS[] = lens_element[](
    //              RADIUS             THICKNESS             MATERIAL     APERTURE           
    lens_element(    11.1000 * 0.001,      1.4000 * 0.001,       N_SK5,      5.7391 * 0.001,  true) /* eta: 1.600 -> 1.600 */,
    lens_element( 10000.0000 * 0.001,      0.4000 * 0.001,      BK7G18,      5.7391 * 0.001,  true) /* eta: 1.530 -> 1.529 */,
    lens_element(    10.2000 * 0.001,      4.2609 * 0.001,         AIR,      4.7391 * 0.001,  true),
    lens_element(     0.0000 * 0.001,      4.2391 * 0.001,         AIR,      1.1087 * 0.001,  true),
    lens_element(   -10.2000 * 0.001,      0.4000 * 0.001,      BK7G18,      4.9565 * 0.001,  true) /* eta: 1.530 -> 1.529 */,
    lens_element( 10000.0000 * 0.001,      1.4000 * 0.001,       N_SK5,      5.7391 * 0.001,  true) /* eta: 1.600 -> 1.600 */,
    lens_element(   -11.1000 * 0.001,      0.0000 * 0.001,         AIR,      5.7391 * 0.001,  true)
);
const sensor_data CAMERA_SENSOR = sensor_data(90.0);

#elif (LENS_TYPE == 7)

// Perle
const lens_element LENS_ELEMENTS[] = lens_element[](
    //              RADIUS             THICKNESS             MATERIAL     APERTURE           
    lens_element(    15.6000 * 0.001,      5.2200 * 0.001,     N_BALF4,     15.5294 * 0.001,  true) /* eta: 1.589 -> 1.592 */,
    lens_element(    20.1000 * 0.001,      0.1200 * 0.001,         AIR,     15.5294 * 0.001,  true),
    lens_element(    13.0000 * 0.001,      0.9300 * 0.001,     P_SK58A,     12.3529 * 0.001,  true) /* eta: 1.606 -> 1.601 */,
    lens_element(    11.0000 * 0.001,     10.4706 * 0.001,         AIR,     10.8235 * 0.001,  true),
    lens_element(     0.0000 * 0.001,      9.5294 * 0.001,         AIR,      3.0000 * 0.001,  true),
    lens_element(   -11.0000 * 0.001,      0.9300 * 0.001,     P_SK58A,     10.8235 * 0.001,  true) /* eta: 1.606 -> 1.601 */,
    lens_element(   -13.0000 * 0.001,      0.1200 * 0.001,         AIR,     12.9412 * 0.001,  true),
    lens_element(   -20.1000 * 0.001,      5.2200 * 0.001,     N_BALF4,     15.5294 * 0.001,  true) /* eta: 1.589 -> 1.592 */,
    lens_element(   -15.6000 * 0.001,      0.0000 * 0.001,         AIR,     15.5294 * 0.001,  true)
);
const sensor_data CAMERA_SENSOR = sensor_data(100.0);

#elif (LENS_TYPE == 8)

// Photographic objective
const lens_element LENS_ELEMENTS[] = lens_element[](
    //              RADIUS             THICKNESS             MATERIAL     APERTURE           
    lens_element(    20.4100 * 0.001,      1.3000 * 0.001,     N_BALF5,      9.8925 * 0.001,  true) /* eta: 1.555 -> 1.560 */,
    lens_element(     9.6200 * 0.001,      2.5000 * 0.001,       N_ZK7,      7.4194 * 0.001,  true) /* eta: 1.519 -> 1.518 */,
    lens_element(    33.2900 * 0.001,      1.2903 * 0.001,         AIR,      7.4194 * 0.001,  true),
    lens_element(     0.0000 * 0.001,      5.7097 * 0.001,         AIR,      2.7419 * 0.001,  true),
    lens_element(   -15.8900 * 0.001,      6.7000 * 0.001,      N_SK11,      9.8925 * 0.001,  true) /* eta: 1.574 -> 1.575 */,
    lens_element(    -9.6200 * 0.001,      1.3000 * 0.001,      N_BAK2,      9.8925 * 0.001,  true) /* eta: 1.548 -> 1.551 */,
    lens_element(   -17.9800 * 0.001,      0.0000 * 0.001,         AIR,      9.8925 * 0.001,  true)
);
const sensor_data CAMERA_SENSOR = sensor_data(80.0);

#elif (LENS_TYPE == 9)

// Kino-Plasmat
const lens_element LENS_ELEMENTS[] = lens_element[](
    //              RADIUS             THICKNESS             MATERIAL     APERTURE           
    lens_element(    72.9000 * 0.001,     16.9800 * 0.001,       N_SK2,     36.6667 * 0.001,  true) /* eta: 1.621 -> 1.620 */,
    lens_element(  -243.0000 * 0.001,      9.6900 * 0.001,         AIR,     36.6667 * 0.001,  true),
    lens_element(   -55.8900 * 0.001,      2.4000 * 0.001,      N_PK51,     30.5556 * 0.001,  true) /* eta: 1.540 -> 1.537 */,
    lens_element(    85.0600 * 0.001,      7.2900 * 0.001,       N_SK2,     31.6667 * 0.001,  true) /* eta: 1.621 -> 1.620 */,
    lens_element(  -182.3000 * 0.001,      0.8333 * 0.001,         AIR,     30.0000 * 0.001,  true),
    lens_element(     0.0000 * 0.001,      1.6067 * 0.001,         AIR,      7.0833 * 0.001,  true),
    lens_element(   182.3000 * 0.001,      7.2900 * 0.001,       N_SK2,     30.5556 * 0.001,  true) /* eta: 1.621 -> 1.620 */,
    lens_element(   -85.0600 * 0.001,      2.4000 * 0.001,      N_PK51,     30.5556 * 0.001,  true) /* eta: 1.540 -> 1.537 */,
    lens_element(    55.8900 * 0.001,      9.6900 * 0.001,         AIR,     30.5556 * 0.001,  true),
    lens_element(   243.0000 * 0.001,     16.9800 * 0.001,       N_SK2,     34.1667 * 0.001,  true) /* eta: 1.621 -> 1.620 */,
    lens_element(   -72.9000 * 0.001,      0.0000 * 0.001,         AIR,     34.1667 * 0.001,  true)
);
const sensor_data CAMERA_SENSOR = sensor_data(60.0);

#elif (LENS_TYPE == 10)

// Pantar
const lens_element LENS_ELEMENTS[] = lens_element[](
    //              RADIUS             THICKNESS             MATERIAL     APERTURE           
    lens_element(     0.0000 * 0.001,      2.0000 * 0.001,         AIR,      4.0625 * 0.001,  true),
    lens_element(   -13.5100 * 0.001,      1.0000 * 0.001,       N_SK2,      4.7500 * 0.001,  true) /* eta: 1.620 -> 1.620 */,
    lens_element(    -6.9000 * 0.001,      1.2000 * 0.001,     N_PK52A,      4.7500 * 0.001,  true) /* eta: 1.500 -> 1.504 */,
    lens_element(    -5.4700 * 0.001,      0.5000 * 0.001,      N_BAK2,      4.5833 * 0.001,  true) /* eta: 1.550 -> 1.551 */,
    lens_element(    22.6200 * 0.001,      1.8000 * 0.001,      N_SK14,      5.5000 * 0.001,  true) /* eta: 1.610 -> 1.615 */,
    lens_element(   -14.9700 * 0.001,      0.0000 * 0.001,         AIR,      5.5000 * 0.001,  true)
);
const sensor_data CAMERA_SENSOR = sensor_data(110.0);

#endif

lens_element rearLensElement() {
    return LENS_ELEMENTS[LENS_ELEMENTS.length() - 1];
}

lens_element frontLensElement() {
    return LENS_ELEMENTS[0];
}

float rearLensElementZ() {
    return -rearLensElement().thickness - renderState.rearThicknessDelta;
}

float frontLensElementZ() {
    return -renderState.rearThicknessDelta - renderState.lensFrontZ;
}

#endif // _CAMERA_CONFIGURATION_GLSL