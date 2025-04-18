#ifndef _LENS_REFLECTION_GLSL
#define _LENS_REFLECTION_GLSL 1

#include "/lib/reflection/sellmeier.glsl"
#include "/lib/reflection/fresnel.glsl"
#include "/lib/reflection/thinfilm.glsl"

struct coating_layer {
    sellmeier_coeffs material;
    int wavelength;
    float tDenom;
};

const coating_layer COATING_LAYERS[] = coating_layer[](
    coating_layer(MgF2, 550, 4.0),
    coating_layer(ZrO2, 550, 2.0),
    coating_layer(Al2O3, 550, 4.0)
);

float getLensCoatingThickness(sellmeier_coeffs material, int wavelength, float denom) {
    return float(wavelength) / (denom * sellmeier(material, wavelength)); 
}

vec2 computeLensElementReflectance(float cosTheta, int lambda, float currentEta, float transmittedEta, bool coated) {
    if (currentEta == transmittedEta) {
        return vec2(0.0, 1.0);
    } else if (coated && (currentEta == 1.0 || transmittedEta == 1.0)) {
        film_stack stack = beginFilmStack(cosTheta, float(lambda), complexFloat(currentEta, 0.0));
        for (int i = 0; i < COATING_LAYERS.length(); i++) {
            int index = (currentEta == 1.0) ? i : COATING_LAYERS.length() - 1 - i;
            coating_layer layer = COATING_LAYERS[index];
            float eta = sellmeier(layer.material, lambda);
            float thickness = getLensCoatingThickness(layer.material, layer.wavelength, layer.tDenom);
            addThinFilmLayer(stack, complexFloat(eta, 0.0), thickness);
        }
        return endFilmStack(stack, complexFloat(transmittedEta, 0.0));
    } else {
        float R = fresnelDielectric(cosTheta, currentEta, transmittedEta);
        return vec2(R, 1.0 - R);
    }
}

#endif // _LENS_REFLECTION_GLSL
