#ifndef _DEBUG_TEXT_GLSL
#define _DEBUG_TEXT_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/debug/text_renderer.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/lens/reflection.glsl"
#include "/lib/settings.glsl"

void printLensType() {
#if (LENS_TYPE == 0)
	printString((_L, _e, _n, _s, _colon, _space, _D, _o, _u, _b, _l, _e, _space, _G, _a, _u, _s, _s));
	printLine();
#elif (LENS_TYPE == 1)
	printString((_L, _e, _n, _s, _colon, _space, _F, _i, _s, _h, _e, _y, _e));
	printLine();
#elif (LENS_TYPE == 2)
    printString((_L, _e, _n, _s, _colon, _space, _T, _e, _s, _s, _a, _r));
    printLine();
#elif (LENS_TYPE == 3)
    printString((_L, _e, _n, _s, _colon, _space, _C, _o, _o, _k, _e, _space, _T, _r, _i, _p, _l, _e, _t));
    printLine();
#endif
}

void printCameraSettings() {
    printString((_S, _h, _u, _t, _t, _e, _r, _space, _s, _p, _e, _e, _d, _colon, _space,  _1, _slash));
	printInt(int(SHUTTER_SPEED));
	printChar(_s);
	printLine();

	printString((_I, _S, _O, _space));
	printInt(int(ISO));

	text.fpPrecision = 2;

	printString((_space, _space, _f, _slash));
	printFloat(round(renderState.fNumber * 100.0) / 100.0);
	printLine();
}

void printCoatingInfo() {
    printString((_A, _R, _space, _C, _o, _a, _t, _i, _n, _g, _colon, _space));

    int coatedElements = 0;
    int totalElements = 0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        if (LENS_ELEMENTS[i].curvature == 0.0) {
            continue;
        }
        if (LENS_ELEMENTS[i].coated && (i == 0 || LENS_ELEMENTS[i].glass == AIR || LENS_ELEMENTS[i - 1].glass == AIR)) {
            coatedElements++;
        }
        totalElements++;
    }

    printInt(coatedElements);
    printChar(_slash);
    printInt(totalElements);

    printChar(_space);
    printInt(int(getLensCoatingThickness()));
    printString((_n, _m, _space));

    if (AR_COATING_MATERIAL == MgF2) {
        printString((_M, _g, _F, _2));
    }

    printLine();
}

void renderDebugText(inout vec3 color, ivec2 resolution, ivec2 position) {
    beginText(resolution, position);

    printLensType();
    printCameraSettings();
    printCoatingInfo();

	endText(color);
}

#endif // _DEBUG_TEXT_GLSL