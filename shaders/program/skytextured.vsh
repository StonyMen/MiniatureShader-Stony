#define GBUFFERS_SKYTEXTURED

#include "/shader.h"

varying vec2 texUV;
varying float fogMix;
varying vec4 color;

#include "/common/math.glsl"
#include "/common/transformations.glsl"
#include "/common/getViewPosition.vsh"
#include "/common/getFogMix.vsh"

void main() {
   gl_Position = ftransform();

   color = gl_Color;
   texUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

   // the sky pass keeps the camera's rotation, so this is the direction the
   // vertex sits in at its fixed radius - which is what the fog needs
   fogMix = getFogMix(view2feet(getViewPosition()));
}
