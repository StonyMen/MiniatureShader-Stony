#define GBUFFERS_SKYTEXTURED

#include "/shader.h"

uniform sampler2D gtexture;
uniform vec3 fogColor;

varying vec2 texUV;
varying float fogMix;
varying vec4 color;

void main() {
   vec4 albedo = texture2D(gtexture, texUV);

   // vanilla dims the sun and moon in rain through the alpha of the colour
   // modulator and never touches their rgb
   albedo.a *= color.a;

   // transparent texels must not write depth, or they would clip the stars
   // that are drawn right after them
   if (albedo.a == 0.0) {
      discard;
   }

   // sun and moon: the only sky draw that sits far enough out for a water or
   // blindness fog to swallow it, so fade them into the fog instead of letting
   // them punch through a sky that is already fogged
   gl_FragData[0] = vec4(mix(albedo.rgb, fogColor, fogMix), albedo.a * (1.0 - fogMix));
}
