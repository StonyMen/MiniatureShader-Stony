#define GBUFFERS_CLOUDS

#include "/shader.h"

uniform int isEyeInWater;

varying float fogMix;
varying float cloudTopness;
varying vec2 texUV;
varying vec3 viewDir;
varying vec4 color;

#include "/common/math.glsl"
#include "/common/transformations.glsl"
#include "/common/getViewPosition.vsh"
#include "/common/getFogMix.vsh"

void main() {
	gl_Position = ftransform();

	vec3 viewPos = getViewPosition();
	vec3 feetPos = view2feet(viewPos);

	color   = gl_Color;
	texUV   = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	fogMix  = getFogMix(feetPos);
	viewDir = normalize(viewPos);

	// since 1.17 the cloud layer is a slab of CLOUD_THICKNESS blocks instead of
	// a flat sheet, so the height of the fragment is all it takes to know
	// whether this is the lit top of a cloud or its shaded underside
	float worldY = feetPos.y + cameraPosition.y;

	cloudTopness = rescale(worldY, CLOUD_HEIGHT, CLOUD_HEIGHT + CLOUD_THICKNESS);
}
