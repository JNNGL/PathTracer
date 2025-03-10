#include "/lib/buffer/state.glsl"
#include "/lib/lighting/environment.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/reflection/bsdf.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/projection.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex2;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPositionFract;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 2 */
layout(location = 0) out vec3 color;

void main() {
	vec3 seed = vec3(texcoord, float(renderState.frame));

	vec2 filmSample = texcoord + random2(seed) / vec2(viewWidth, viewHeight);
	vec3 rayOrigin = projectAndDivide(gbufferProjectionInverse, vec3(filmSample * 2.0 - 1.0, 0.0));
	vec3 rayDirection = projectAndDivide(gbufferProjectionInverse, vec3(filmSample * 2.0 - 1.0, 1.0));
	rayOrigin = (gbufferModelViewInverse * vec4(rayOrigin, 1.0)).xyz + cameraPositionFract;
	rayDirection = normalize((gbufferModelViewInverse * vec4(rayDirection, 1.0)).xyz);

	ray r = ray(rayOrigin, rayDirection);

	vec3 L = vec3(0.0);
	vec3 throughput = vec3(1.0);

	for (int i = 0; i < 5; i++) {
		intersection it = traceRay(colortex10, r, i == 0 ? 1024 : 128);
		if (it.t < 0.0) {
			if (i == 0)
				L += throughput * environmentMap(r);
			break;
		}
		
		material mat = decodeMaterial(it.tbn, it.albedo, textureLod(colortex11, it.uv, 0), textureLod(colortex12, it.uv, 0));

		L += throughput * mat.emission;

		float pdfDirect;
		vec3 skyDirection = sampleEnvironmentMap(random3(seed), pdfDirect);
		if (dot(skyDirection, it.normal) > 0.0 && dot(skyDirection, mat.normal) > 0.0 && pdfDirect > 0.0) {
			vec3 shadowOrigin = r.origin + r.direction * it.t + it.normal * 0.001;
			float visibility = float(!traceShadowRay(colortex10, ray(shadowOrigin, skyDirection)));
			if (visibility > 0.0) {
				bsdf_value bsdfDirect = evaluateBSDF(mat, seed, skyDirection, -r.direction, false);
				L += environmentMap(skyDirection) * (bsdfDirect.full / pdfDirect) * throughput * dot(skyDirection, mat.normal) * visibility;
			}
		}

		bsdf_sample bsdfSample;
		if (!sampleBSDF(bsdfSample, mat, seed, -r.direction, it.normal)) {
			break;
		}

		float costh = dot(bsdfSample.direction, mat.normal);

		throughput *= (bsdfSample.value.full / bsdfSample.pdf) * abs(costh);
		r = ray(r.origin + r.direction * it.t + it.normal * (sign(costh) * 0.001), bsdfSample.direction);
	}
	
	if (any(isnan(L)) || any(isinf(L))) {
		L = vec3(0.0);
	}

	L = max(vec3(0.0), L);

	vec3 history = texture(colortex2, texcoord).rgb;
	color = mix(history, L, 1.0 / float(renderState.frame + 1));
}