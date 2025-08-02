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
const sensor_data CAMERA_SENSOR = sensor_data(135.0);

#elif (LENS_TYPE == 2)

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

const lens_element LENS_ELEMENTS[] = lens_element[](
    lens_element( 26.585199 * 0.001, 7.736537 * 0.001, N_LASF31A, 11.676172 * 0.001, true),
    lens_element( 43.429037 * 0.001, 3.435887 * 0.001, AIR,       8.940243  * 0.001, true),
    lens_element(-55.415591 * 0.001, 3.999980 * 0.001, N_SF14,    7.469473  * 0.001, true),
    lens_element( 29.198443 * 0.001, 2.127319 * 0.001, AIR,       6.034548  * 0.001, true),
    lens_element( 55.521418 * 0.001, 5.365190 * 0.001, N_LASF31A, 7.457009  * 0.001, true),
    lens_element(-43.266572 * 0.001, 0.0      * 0.001, AIR,       8.595248  * 0.001, true)
);
const sensor_data CAMERA_SENSOR = sensor_data(45.0);

#elif (LENS_TYPE == 4)

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