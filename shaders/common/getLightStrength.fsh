#include "/common/getShadowDistortion.glsl"

// the light that reaches a surface, as a colour: shadowtex1 holds the opaque
// geometry, shadowtex0 all of it, shadowcolor0 the tint of a translucent caster
vec3 getLightStrength(float diffuse, float skyLight, vec3 feetPos) {
   // reduce diffuse with sky light
   diffuse *= rescale(skyLight, 0.3137, 0.6235);

   #ifdef GBUFFERS_HAND
      return vec3(0.5*diffuse);
   #endif

   #if SHADOW_PIXEL > 0
      vec3 pos = world2feet(bandify(feet2world(feetPos), SHADOW_PIXEL));
   #else
      vec3 pos = feetPos;
   #endif

   float posDistance = squaredLength(pos);
   vec4 shadowView   = shadowModelView * vec4(pos, 1.0);
   vec4 shadowClip   = shadowProjection * shadowView;

   shadowClip.xyz = getShadowDistortion(shadowClip.xyz);

   vec3 shadowUV = clip2screen(shadowClip);

   if (posDistance < SHADOW_MAX_DIST_SQUARED &&
      diffuse    > 0.0 && shadowUV.z < 1.0 &&
      shadowUV.s > 0.0 && shadowUV.s < 1.0 &&
      shadowUV.t > 0.0 && shadowUV.t < 1.0)
   {
      float shadowFade  = 1.0 - posDistance * INV_SHADOW_MAX_DIST_SQUARED;
      float depthScale  = 3.0 / shadowProjection[2].z;

      // mode 0 ignores translucent casters, so only the opaque layer counts
      #if COLORED_SHADOWS > 0
         float casterDepth = texture2D(shadowtex0, shadowUV.st).x;
      #else
         float casterDepth = texture2D(shadowtex1, shadowUV.st).x;
      #endif

      float occlusion = clamp((casterDepth - shadowUV.z) * depthScale, 0.0, 1.0);

      // an opaque caster stops the light completely; shadowcolor0 is only trusted
      // when nothing opaque is there
      vec3 blocker = vec3(0.0);

      #if COLORED_SHADOWS > 0
         float opaqueDepth = texture2D(shadowtex1, shadowUV.st).x;
         float opaque = clamp((opaqueDepth - shadowUV.z) * depthScale, 0.0, 1.0);

         if (opaque <= 0.0) {
            // the caster's alpha is how much material is there (about 0.7 for
            // water, 0 for the empty middle of glass), so a transparent pixel
            // fades the shadow out instead of only tinting it
            vec4 caster = texture2D(shadowcolor0, shadowUV.st);

            // fixed look value: translucent shadow strength - a fully opaque caster
            // passes 55% of the light; mode 2 keeps its tint, mode 1 its luminance
            #if COLORED_SHADOWS == 2
               vec3 tint = caster.rgb * 0.55;
            #else
               vec3 tint = vec3(luma(caster.rgb) * 0.55);
            #endif

            blocker = mix(vec3(1.0), tint, caster.a);
         }
      #endif

      return diffuse * mix(vec3(1.0), blocker, occlusion * shadowFade);
   }

   return vec3(diffuse);
}
