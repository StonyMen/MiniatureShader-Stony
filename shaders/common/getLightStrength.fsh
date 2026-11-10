#include "/common/getShadowDistortion.glsl"

// the light that reaches a surface, as a colour instead of a single number: 1
// is full light, 0 is full shadow. shadowtex1 only holds the opaque geometry,
// shadowtex0 holds all of it, so when the first one is clear but the second is
// not, the thing blocking the light is translucent - and then shadowcolor0
// tells us how much light it filters and, in the coloured mode, with which tint
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

      // shadowtex0 holds every caster, shadowtex1 only the opaque ones. mode 0
      // ignores translucent casters entirely, so glass and water do not block
      // any light and only the opaque layer is allowed to count
      #if COLORED_SHADOWS > 0
         float casterDepth = texture2D(shadowtex0, shadowUV.st).x;
      #else
         float casterDepth = texture2D(shadowtex1, shadowUV.st).x;
      #endif

      float occlusion = clamp((casterDepth - shadowUV.z) * depthScale, 0.0, 1.0);

      // an opaque caster stops the light completely: black. whatever is in
      // shadowcolor0 belongs to the block in front, and it is only trusted when
      // nothing opaque is there, so the two cases cannot be mixed up
      vec3 blocker = vec3(0.0);

      #if COLORED_SHADOWS > 0
         float opaqueDepth = texture2D(shadowtex1, shadowUV.st).x;
         float opaque = clamp((opaqueDepth - shadowUV.z) * depthScale, 0.0, 1.0);

         if (opaque <= 0.0) {
            // shadowcolor0 carries the caster's own alpha, which is how much of
            // the material is really there at this pixel: around 0.7 for a water
            // surface, 1.0 for the frame of a glass block and 0 for the empty
            // middle of one. that alpha is what decides how deep the shadow goes,
            // so a transparent pixel fades the shadow out towards full light
            // instead of just tinting it
            vec4 caster = texture2D(shadowcolor0, shadowUV.st);

            // mode 2 keeps the block's tint; mode 1 keeps only its brightness,
            // so the shadow is neutral grey but still as deep as the material
            #if COLORED_SHADOWS == 2
               vec3 tint = caster.rgb * SHADOW_TRANSLUCENT_STRENGTH;
            #else
               vec3 tint = vec3(luma(caster.rgb) * SHADOW_TRANSLUCENT_STRENGTH);
            #endif

            blocker = mix(vec3(1.0), tint, caster.a);
         }
      #endif

      return diffuse * mix(vec3(1.0), blocker, occlusion * shadowFade);
   }

   return vec3(diffuse);
}
