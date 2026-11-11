#version 120

#define THE_END

#include "/shader.h"

uniform float frameTimeCounter;
uniform sampler2D gtexture;
uniform vec3 fogColor;

varying vec2 texUV;
varying vec3 feetPos;
varying vec4 color;

void main() {
   vec4 albedo = texture2D(gtexture, texUV) * color;

   albedo.rgb = mix(albedo.rgb, albedo.rgb * fogColor, 0.9);

   float theta   = mod(atan(feetPos.y, feetPos.x), PI) - HALF_PI;
   float phi     = acos(feetPos.z / length(feetPos))   - HALF_PI;
   float slice   = ceil(atan(theta, phi) * END_STARS_AMOUNT);
   float offset  = cos(slice);
   float invDist = offset / (theta*theta + phi*phi);
   float time    = frameTimeCounter * END_STARS_SPEED;

   slice *= offset;

   // fixed look value: per-channel star trail decay (R,G,B,A) - bigger k gives
   // shorter, sharper streaks
   vec4 stars = exp(fract(invDist + slice + time) * -vec4(200, 500, 100, 100)) / invDist;

   gl_FragData[0] = albedo + clamp(stars, vec4(0.0), vec4(1.0)) * END_STARS_OPACITY;
}