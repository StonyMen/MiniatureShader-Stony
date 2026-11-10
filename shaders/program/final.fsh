#include "/shader.h"

uniform float far;
uniform int isEyeInWater;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform vec3 fogColor;

varying vec2 texUV;

#include "/common/math.glsl"
#include "/common/transformations.glsl"
#include "/common/getClouds.fsh"
#include "/common/getReflectionColor.fsh"

// distance (in blocks) of the surface stored in the depth buffer
float getDistance(vec2 uv, float depth) {
   // depth 1.0 is the far plane, where the projection inverse is degenerate
   return depth < 1.0 ? -screen2view(uv, depth).z : 1e6;
}

void main() {
   vec3 scene       = texture2D(colortex0, texUV).rgb;
   vec4 translucent = texture2D(colortex2, texUV); // premultiplied

   // this depth doesn't contain the translucent geometry, so it can't cull the
   // clouds, which sit behind it
   float opaqueDepth = texture2D(depthtex1, texUV).x;

   vec3 color = scene;

   #ifdef OVERWORLD
      vec3 worldDir  = normalize(view2eye(normalize(screen2view(texUV, 0.5))));
      vec3 cloudTint = opaqueDepth > 0.9999 ? scene : fogColor;
      vec4 cloud     = getClouds(gbufferModelViewInverse[3].xyz,
                                 worldDir,
                                 getDistance(texUV, opaqueDepth),
                                 cloudTint);

      color = cloud.rgb + (1.0 - cloud.a) * color;
   #endif

   // the translucent geometry is composited on top of the clouds, which is what
   // keeps them visible through water, ice and stained glass
   color = translucent.rgb + (1.0 - translucent.a) * color;

   vec4 reflectivityAndRoughness = texture2D(colortex7, texUV);
   float reflectivity = reflectivityAndRoughness.x;
   float roughness = reflectivityAndRoughness.y;

   if (reflectivity > MIN_REFLECTIVITY && abs(reflectivityAndRoughness.z - 0.5) < 0.01) {
      // the normal doesn't come premultiplied by the normal matrix to
      // avoid the modelview transformations when view bobbing is on
      // which causes severe artifacts when moving
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

      // when underwater looking up at the water surface from below,
      // there is nothing to reflect, so skip the reflection entirely
      if (isEyeInWater == 0 || feetPos.y <= 0.0) {
         vec4 reflectionColor = getReflectionColor(depth, normal, viewPos);

         color = mix(
            color,
            reflectionColor.rgb,
            reflectionColor.a * reflectivity * 0.1*REFLECTIONS
         );
      }
   }

   gl_FragData[0] = vec4(color, 1.0);
}
