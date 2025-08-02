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

#ifndef _TIME_GLSL
#define _TIME_GLSL 1

#include "/lib/settings.glsl"

uniform ivec3 currentDate;
uniform ivec3 currentTime;
uniform ivec2 currentYearTime;

#define UTC(hour, minute) ((hour < 0 ? -1 : 1) * (abs(hour) * 3600 + minute * 60))

const int UTC_OFFSETS[] = int[](
    UTC(-12, 00), UTC(-11, 00), UTC(-10, 00), UTC(-09, 30), 
    UTC(-09, 00), UTC(-08, 00), UTC(-07, 00), UTC(-06, 00), 
    UTC(-05, 00), UTC(-04, 00), UTC(-03, 30), UTC(-03, 00),
    UTC(-02, 00), UTC(-01, 00), UTC(+00, 00), UTC(+01, 00), 
    UTC(+02, 00), UTC(+03, 00), UTC(+03, 30), UTC(+04, 00), 
    UTC(+04, 30), UTC(+05, 00), UTC(+05, 30), UTC(+05, 45),
    UTC(+06, 00), UTC(+06, 30), UTC(+07, 00), UTC(+08, 00), 
    UTC(+08, 45), UTC(+09, 00), UTC(+09, 30), UTC(+10, 00), 
    UTC(+10, 30), UTC(+11, 00), UTC(+12, 00), UTC(+12, 45),
    UTC(+13, 00), UTC(+14, 00)
);

struct datetime {
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
};

uint datetimeToUnix(datetime dt) {
    dt.year -= int(dt.month <= 2);
    int era = (dt.year >= 0 ? dt.year : dt.year - 399) / 400;
    uint yoe = uint(dt.year - era * 400);
    uint doy = uint((153 * (dt.month + (dt.month > 2 ? -3 : 9)) + 2) / 5 + dt.day - 1);
    uint doe = yoe * 365u + yoe / 4u - yoe / 100u + doy;
    uint days = era * 146097u + doe - 719468u;
    return days * 86400u + uint(dt.hour) * 3600u + uint(dt.minute) * 60u + uint(dt.second);
}

datetime unixToDatetime(uint unix) {
    datetime dt;

    dt.second = int(unix % 60u);
    unix /= 60u;
    dt.minute = int(unix % 60u);
    unix /= 60u;
    dt.hour = int(unix % 24u);
    unix /= 24u;

    uint z = unix + 719468u;
    uint era = z / 146097u;
    uint doe = z - era * 146097u;
    uint yoe = (doe - doe / 1460u + doe / 36524u - doe / 146096u) / 365u;
    uint y = yoe + era * 400u;
    uint doy = doe - (yoe * 365u + yoe / 4u - yoe / 100u);
    uint mp = (doy * 5u + 2u) / 153u;

    dt.day = int(doy - (mp * 153u + 2u) / 5u + 1u);
    dt.month = int(mp) + (mp < 10u ? 3 : -9);
    dt.year = int(y) + int(dt.month <= 2);

    return dt;
}

int getLeapYears(int year) {
    year--;
    return year / 4 - year / 100 + year / 400;
}

bool isLeapYear(int year) {
    return ((year % 100) != 0 && (year % 4) == 0) || ((year % 100) == 0 && (year % 400) == 0);
}

int daysInMonth(int month) {
    const int[] nDays = int[](31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    return nDays[month - 1];
}

int daysInMonth(int month, int year) {
    return daysInMonth(month) + int(month == 2 && isLeapYear(year));
}

datetime currentLocalTime() {
    return datetime(currentDate.x, currentDate.y, currentDate.z, currentTime.x, currentTime.y, currentTime.z);
}

datetime convertToUniversalTime(datetime dt) {
    int tzOffset = UTC_OFFSETS[TIME_ZONE];
    return unixToDatetime(datetimeToUnix(dt) - tzOffset);
}

datetime currentUniversalTime() {
    return convertToUniversalTime(currentLocalTime());
}

#endif // _TIME_GLSL