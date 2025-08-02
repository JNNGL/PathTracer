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

#ifndef _RANDOM_GLSL
#define _RANDOM_GLSL 1

struct prng_state {
    vec3 seed;
};

prng_state global_prngState;

prng_state initLocalPRNG(vec2 texcoord, int frame) {
    return prng_state(vec3(texcoord, float(frame)));
}

void initGlobalPRNG(vec2 texcoord, int frame) {
    global_prngState = prng_state(vec3(texcoord, float(frame)));
}

uint hash(uint x) {
    x += (x << 10u);
    x ^= (x >> 6u);
    x += (x << 3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

uint hash(uvec3 v) {
    return hash(v.x ^ hash(v.y) ^ hash(v.z));
}

float floatConstruct(uint m) {
    const uint ieeeMantissa = 0x007FFFFFu;
    const uint ieeeOne = 0x3F800000u;

    m &= ieeeMantissa;
    m |= ieeeOne;

    float f = uintBitsToFloat(m);
    return fract(f - 1.0);
}

void advancePRNG(inout prng_state state) {
    state.seed += 1.0;
}

uint hashPRNG(prng_state state) {
    return hash(floatBitsToUint(state.seed));
}

float random1(inout prng_state state) {
    advancePRNG(state);
    return floatConstruct(hashPRNG(state));
}
float random1() {
    return random1(global_prngState);
}

vec2 random2(inout prng_state state) {
    return vec2(random1(state), random1(state));
}
vec2 random2() {
    return random2(global_prngState);
}

vec3 random3(inout prng_state state) {
    return vec3(random2(state), random1(state));
}
vec3 random3() {
    return random3(global_prngState);
}

vec4 random4(inout prng_state state) {
    return vec4(random2(state), random2(state));
}
vec4 random4() {
    return random4(global_prngState);
}

#endif // _RANDOM_GLSL