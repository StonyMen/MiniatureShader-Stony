vec3 getTorchColor(float torchLight, vec3 ambient, vec3 feetPos) {
   // clamp: Tweakeroo gamma can push screenBrightness > 1, which would overdrive the mixes below
   float brightness = clamp(screenBrightness, 0.0, 1.0);

   float strength = rescale(torchLight, TORCH_UV_SCALE.x, TORCH_UV_SCALE.y);

   #if HAND_DYNAMIC_LIGHTING >= 0

      strength = max(strength, rescale(float(heldBlockLightValue) - SQRT_2 * length(feetPos), 0.0, 15.0));

   #endif

   strength = mix(strength*strength, smoothe(strength), brightness);
   strength = mix(strength*strength, strength, max(1.0 - brightness, eyeBrightnessSmooth.y/240.0));

   // FIXED LOOK VALUE - torch light falloff (used to be TORCH_OUTER_COLOR,
   // TORCH_MIDDLE_COLOR and TORCH_INNER_COLOR). strength goes 0 (far from the
   // torch) -> 1 (right at it), and the three colours are the rings of that
   // gradient:
   //   vec3(1.0, 0.55, 0.2) deep orange at the outer edge
   //   vec3(1.0, 0.8,  0.6) amber in the middle (linear mix by strength)
   //   vec3(1.0, 0.85, 0.7) warm white core, faded in by slopeTo1(..., 8.0)
   // the result is ADDED to ambient and scaled by (1 - ambient luma), so it
   // only shows up in dark places. edit the three vec3s to re-tint torch light.
   return max(0.0, 1.0 - luma(ambient)) * strength * mix(
      mix(vec3(1.0, 0.55, 0.2), vec3(1.0, 0.8, 0.6), strength),
      vec3(1.0, 0.85, 0.7),
      slopeTo1(strength, 8.0)
   );
}