#include "/lib/buffer/state.glsl"
#include "/lib/lighting/environment.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/reflection/bsdf.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/spectral/sampling.glsl"
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
	initGlobalPRNG(texcoord, renderState.frame);

	vec2 filmSample = texcoord + random2() / vec2(viewWidth, viewHeight);
	vec3 rayOrigin = projectAndDivide(gbufferProjectionInverse, vec3(filmSample * 2.0 - 1.0, 0.0));
	vec3 rayDirection = projectAndDivide(gbufferProjectionInverse, vec3(filmSample * 2.0 - 1.0, 1.0));
	rayOrigin = (gbufferModelViewInverse * vec4(rayOrigin, 1.0)).xyz + cameraPositionFract;
	rayDirection = normalize((gbufferModelViewInverse * vec4(rayDirection, 1.0)).xyz);

	ray r = ray(rayOrigin, rayDirection);

	int lambda = sampleWavelength(random1());

	float L = 0.0;
	float throughput = 1.0;
	bsdf_sample bsdfSample;

	for (int i = 0; i < 5; i++) {
		intersection it = traceRay(colortex10, r, i == 0 ? 1024 : 64);
		if (it.t < 0.0) {
			float misWeight = i == 0 ? 1.0 : bsdfSample.pdf / (bsdfSample.pdf + environmentMapWeight(lambda, r));
			L += misWeight * throughput * environmentMap(lambda, r);
			break;
		}

		vec3 w1, w2;
		buildOrthonormalBasis(it.normal, w1, w2);
		mat3 localToWorld = mat3(w1, w2, it.normal);

		vec3 wi = -r.direction * localToWorld;
		
		material mat = decodeMaterial(lambda, it.tbn, it.albedo, textureLod(colortex11, it.uv, 0), textureLod(colortex12, it.uv, 0));

		L += throughput * mat.emission;

		float pdfDirect;
		vec3 skyDirection = sampleEnvironmentMap(random3(), pdfDirect);
		if (dot(skyDirection, it.normal) > 0.0 && pdfDirect > 0.0) {
			vec3 shadowOrigin = r.origin + r.direction * it.t + it.normal * 0.001;
			float visibility = float(!traceShadowRay(colortex10, ray(shadowOrigin, skyDirection)));
			if (visibility > 0.0) {
				vec3 wo = skyDirection * localToWorld;
				bsdf_value bsdfDirect = evaluateBSDF(mat, wi, wo, false);
				float environmentWeight = environmentMapWeight(lambda, skyDirection);
				float misWeight = environmentWeight / (environmentWeight + evaluateBSDFSamplePDF(mat, wi, wo));
				L += environmentMap(lambda, skyDirection) * (bsdfDirect.full / pdfDirect) * misWeight * throughput * wo.z * visibility;
			}
		}

		if (!sampleBSDF(bsdfSample, mat, wi)) {
			break;
		}

		throughput *= (bsdfSample.value.full / bsdfSample.pdf) * abs(bsdfSample.direction.z);

		vec3 offset = it.normal * (sign(bsdfSample.direction.z) * 0.001);
		r = ray(r.origin + r.direction * it.t + offset, localToWorld * bsdfSample.direction);
	}

	L /= wavelengthPDF(lambda);

	if (isnan(L) || isinf(L)) {
		L = 0.0;
	}

	vec3 L_xyz = spectrumToXYZ(lambda, L);

	vec3 history = texture(colortex2, texcoord).rgb;
	color = mix(history, L_xyz, 1.0 / float(renderState.frame + 1));
}