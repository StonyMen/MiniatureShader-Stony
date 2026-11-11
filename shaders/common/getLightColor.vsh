vec3 getLightColor(float sunHeight, float skyLight) {
   float sunRedness = 1.0 - clamp(0.2*sunHeight - 3.929, 0.0, 1.0);

   // FIXED LOOK VALUE - moon colour (used to be MOON_COLOR). once sunHeight
   // drops below 0.01 the sun is down and the whole directional light becomes
   // this cool, dim blue (0.1, 0.15, 0.3); above it the warm normalised
   // sunlight on the other branch is used. the final mix desaturates the tint
   // in low skylight. raise all three channels for brighter moonlight, or
   // shift them towards 1.0 for a neutral white night.
   vec3 lightColor = sunHeight > 0.01 ? normalize(vec3(1.0 + clamp(sunRedness, 0.12, 1.0), 1.06, 1.0))
                                      : vec3(0.1, 0.15, 0.3);

   // reduce color burn on dark spots
   return mix(vec3(luma(lightColor)), lightColor, skyLight);
}