#include "/shader.h"

uniform float far;
uniform int isEyeInWater;
uniform sampler2D colortex0;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;

varying vec2 texUV;

#include "/common/math.glsl"
#include "/common/transformations.glsl"
#include "/common/getReflectionColor.fsh"

void main() {
   vec4 color = texture2D(colortex0, texUV);
   vec4 reflectivityAndRoughness = texture2D(colortex7, texUV);
   float reflectivity = reflectivityAndRoughness.x;
   float roughness = reflectivityAndRoughness.y;

   if (reflectivity > MIN_REFLECTIVITY && abs(reflectivityAndRoughness.z - 0.5) < 0.01) {
      // the normal is stored unpremultiplied: premultiplying it makes view
      // bobbing show up as heavy artifacts when moving
      vec3 prenormal = screen2ndc(texture2D(colortex6, texUV).xyz);

      #if WATER_WAVE_SIZE > 0

         if ((abs(prenormal.x) > 0.0 || abs(prenormal.z) > 0.0) && abs(prenormal.y) > 0.3333) {
            prenormal.xyz *= 1.0 / prenormal.y;
            prenormal.xz *= 0.01 * WATER_WAVE_SIZE;
         }

      #endif

      float depth  = texture2D(depthtex0, texUV).x;
      vec3 normal  = eye2view(prenormal);
      vec3 viewPos = screen2view(texUV, depth);
      vec3 feetPos = view2feet(viewPos);
      vec3 worldPos = feet2world(feetPos);
      float pixelDistance = min(1.0, length(feetPos)/16.0);
      float stepSize = stepify(mix(1.0/512.0, 1.0/64.0, pixelDistance), 1.0/512.0);

      normal += roughness * random3(stepify(worldPos, stepSize));
      normal = normalize(normal);

      // per surface: the blocks bake BLOCK_REFLECTIONS into their reflectivity,
      // the water is scaled here
      float reflectionStrength = reflectivity;

      if (reflectivity > WATER_REFLECTIVITY - 0.01) {
         reflectionStrength *= 0.1*WATER_REFLECTION_STRENGTH;
      }

      // looking up at the surface from below, there is nothing to reflect
      if ((isEyeInWater == 0 || feetPos.y <= 0.0) && reflectionStrength > 0.0) {
         vec4 reflectionColor = getReflectionColor(depth, normal, viewPos);

         color.rgb = mix(
            color.rgb,
            reflectionColor.rgb,
            min(reflectionColor.a * reflectionStrength, 1.0)
         );
      }
   }

   gl_FragData[0] = color;
}