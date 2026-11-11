uniform float fogEnd, fogStart;
uniform float near, far;

#if defined GBUFFERS_SKYTEXTURED
   // only needed for the shallow render distance case, where the water
   // fog end never gets closer than the render distance
   uniform int isEyeInWater;
#endif

float calcFogMix(vec3 feetPos, float fogStartMult, float far) {
   float len = length(feetPos);
   float cylinderLen = max(length(feetPos.xz), abs(feetPos.y));

   return max(
      rescale(len, fogStartMult * fogStart, fogEnd),
      rescale(cylinderLen, fogStartMult * (far - clamp(0.1 * far, 4.0, 64.0)), far)
   );
}

float getFogMix(vec3 feetPos) {
   #if defined GBUFFERS_SKYTEXTURED
      // the sun and moon sit at a fixed 100 blocks and the sky behind them is
      // fogged with them in view, so under water they must go with it. rain and
      // blindness only pull the terrain fog in closer, and vanilla never fogs the
      // celestial bodies for those, so leave them alone there
      return isEyeInWater > 0 ? rescale(length(feetPos), fogStart, fogEnd) : 0.0;
   #else

   #if defined VOXY && !defined GBUFFERS_SKYBASIC && !defined GBUFFERS_CLOUDS
      float far = 48000.0;
      float near = 16.0;
   #endif

   #ifndef ENABLE_FOG
      if (fogEnd >= far) {
         return 0.0;
      }
   #endif

   if (fogEnd < far) {
      // a fog effect (like blindness) is active
      return calcFogMix(feetPos, 1.0, far);
   }

   #if defined GBUFFERS_SKYBASIC
      return 0.0;
   #elif defined GBUFFERS_CLOUDS
      return clamp((length(feetPos) - far) * (near * 0.01), 0.0, 1.0);
   #else
      #ifdef OVERWORLD
         float x = worldTime * NORMALIZE_TIME;

         x = clamp(25.0*(x < MIDNIGHT ? SUNSET - x : x - SUNRISE) + 0.3,
                  OVERWORLD_FOG_MIN,
                  OVERWORLD_FOG_MAX);

         x = min(x, 1.0 - rainStrength);
      #else
         float x = 1.0;
      #endif

      return calcFogMix(feetPos, x, far);
   #endif
   #endif
}