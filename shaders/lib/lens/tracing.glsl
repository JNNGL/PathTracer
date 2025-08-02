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

#ifndef _LENS_TRACING_GLSL
#define _LENS_TRACING_GLSL 1

#include "/lib/lens/aperture.glsl"
#include "/lib/lens/common.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/lens/intersection.glsl"
#include "/lib/lens/reflection.glsl"
#include "/lib/utility/random.glsl"

bool traceLensSystem(int lambda, const bool fromScene, bool canReflect, inout ray r, inout float weight, out bool reflected) {
    float z = fromScene ? frontLensElementZ() : -renderState.rearThicknessDelta;
    int i = fromScene ? 0 : LENS_ELEMENTS.length() - 1;

    reflected = false;

    int bounce = 0;
    int nR = 0;

    float currentEta = 1.0;
    while (true) {
        if (bounce++ > 32) {
            return false;
        }

        if (i < 0 || i >= LENS_ELEMENTS.length()) {
            break;
        }

        lens_element element = LENS_ELEMENTS[i];

        z += r.direction.z > 0.0 ? (i > 0 ? LENS_ELEMENTS[i - 1].thickness : 0.0) : -element.thickness;
        
        float t;
        vec3 normal;
        if (element.curvature == 0.0) {
            if (!intersectPlanarLensElement(z, r, t, normal)) {
                return false;
            }
            
            r.origin += t * r.direction;
            if (!insideAperture(r.origin.xy, renderState.apertureRadius)) {
                return false;
            }
        } else {
            if (!intersectSphericalLensElement(element.curvature, z, r, t, normal)) {
                return false;
            }
            
            r.origin += t * r.direction;
            if (!insideCircularAperture(r.origin.xy, element.aperture)) {
                return false;
            }
            
            float transmittedEta = r.direction.z <= 0.0 ? sellmeier((i > 0) ? LENS_ELEMENTS[i - 1].glass : AIR, lambda) : sellmeier(element.glass, lambda);
            vec2 intensities = computeLensElementReflectance(dot(-r.direction, normal), lambda, currentEta, transmittedEta, element.coated);
            
            float reflectionProbability = 0.5 / float(nR + 3);
            if (intensities.x == 0.0 || intensities.x == 1.0) {
                reflectionProbability = intensities.x;
            }
            if (!canReflect) {
                reflectionProbability = 0.0;
            }

            if (random1() < reflectionProbability) {
                weight *= intensities.x / reflectionProbability;
                r.direction = reflect(r.direction, normal);
                reflected = true;
                nR++;
            } else {
                weight *= intensities.y / (1.0 - reflectionProbability);
                r.direction = refract(r.direction, normal, currentEta / transmittedEta);
                if (r.direction == vec3(0.0)) {
                    return false;
                }

                currentEta = transmittedEta;
            }
        }

        i += (r.direction.z <= 0.0 ? -1 : 1);
    }

    if ((fromScene && i < 0) || (!fromScene && i >= LENS_ELEMENTS.length())) {
        return false;
    }

    return true;
}

bool rayExitsLensSystem(int lambda, ray r) {
    float z = -renderState.rearThicknessDelta;

    float currentEta = 1.0;
    for (int i = LENS_ELEMENTS.length() - 1; i >= 0; i--) {
        lens_element element = LENS_ELEMENTS[i];

        z -= element.thickness;
        
        float t;
        vec3 normal;
        if (element.curvature == 0.0) {
            if (!intersectPlanarLensElement(z, r, t, normal)) {
                return false;
            }
            
            r.origin += t * r.direction;
            if (!insideAperture(r.origin.xy, renderState.apertureRadius)) {
                return false;
            }
        } else {
            if (!intersectSphericalLensElement(element.curvature, z, r, t, normal)) {
                return false;
            }
            
            r.origin += t * r.direction;
            if (!insideCircularAperture(r.origin.xy, element.aperture)) {
                return false;
            }
            
            float transmittedEta = sellmeier((i > 0) ? LENS_ELEMENTS[i - 1].glass : AIR, lambda);

            r.direction = refract(r.direction, normal, currentEta / transmittedEta);
            if (r.direction == vec3(0.0)) {
                return false;
            }

            currentEta = transmittedEta;
        }
    }

    return true;
}

bool traceLensSystemFromFilm(int lambda, bool canReflect, inout ray r, inout float weight, out bool reflected) {
    return traceLensSystem(lambda, false, canReflect, r, weight, reflected);
}

bool traceLensSystemFromScene(int lambda, bool canReflect, inout ray r, inout float weight, out bool reflected) {
    return traceLensSystem(lambda, true, canReflect, r, weight, reflected);
}

#endif // _LENS_TRACING_GLSL