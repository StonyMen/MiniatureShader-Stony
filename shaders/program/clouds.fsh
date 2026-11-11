#define GBUFFERS_CLOUDS

#include "/shader.h"

uniform sampler2D gtexture;
uniform vec3 fogColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float rainStrength;

varying float fogMix;
varying float cloudTopness;
varying vec2 texUV;
varying vec3 viewDir;
varying vec4 color;

#include "/common/math.glsl"
#include "/common/transformations.glsl"

// one texel is one cloud block, so an empty alpha next to this one means we are
// on the edge of a block
float cloudEdge(vec2 uv) {
   float texel = 1.0/256.0;
   float around = texture2D(gtexture, uv + vec2(texel, 0.0)).a
                + texture2D(gtexture, uv - vec2(texel, 0.0)).a
                + texture2D(gtexture, uv + vec2(0.0, texel)).a
                + texture2D(gtexture, uv - vec2(0.0, texel)).a;

   return clamp(4.0 - around, 0.0, 1.0);
}

void main() {
   vec4 albedo = texture2D(gtexture, texUV);

   // threshold kept low on purpose: mipmaps blur the alpha at distance and a
   // higher cut would punch holes in far clouds
   if (albedo.a < 0.1) {
      discard;
   }

   vec3 dir     = normalize(viewDir);
   vec3 sunDir  = normalize(sunPosition);
   vec3 moonDir = normalize(moonPosition);

   // the moon takes over once the sun is down, exactly like the vanilla light
   float lightDot = max(dot(dir, sunDir), dot(dir, moonDir));

   // vanilla gives the cloud a colour but never says which light is doing the
   // lighting, so the light colour is rebuilt here: the sun is warm, the moon cold
   float sunHeight = (mat3(gbufferModelViewInverse) * sunDir).y;

   // 1 while the sun is up, 0 once it is gone and only the moon is left
   float daylight = smoothstep(-0.08, 0.02, sunHeight);

   // warm yellow overhead, orange only near the horizon; the range is short on
   // purpose, spreading the warmth over the whole day turns daylight red
   float warmth = (1.0 - rescale(sunHeight, 0.0, 0.22)) * daylight;

   // fixed look value: sunset cloud warmth - how much of the orange reaches the
   // daylight white; 0.0 keeps it white all day, 1.0 gives full orange up to
   // sunHeight 0.22. only the sun is affected
   vec3 sunColor  = mix(vec3(1.0, 0.86, 0.74),
                        vec3(1.0, 0.55, 0.32), warmth * 0.6);

   // the moon is the sun seen through a lot of air: dim and blue
   vec3 moonColor = vec3(0.52, 0.70, 1.0);

   vec3 lightColor = mix(moonColor, sunColor, daylight);

   // rain puts a lid on the sky, so the cloud stops reacting to the light
   float clearSky = 1.0 - rainStrength;

   // the underside catches less light than the top, it looks away from the sky
   float exposure = clamp(lightDot, 0.0, 1.0) * mix(0.6, 1.0, cloudTopness) * clearSky;

   // vanilla colour is the baseline, the light is only added on top of it
   vec3 cloudColor = albedo.rgb * color.rgb
                   * (1.0 + CLOUD_LIGHT_GAIN * exposure * lightColor);

   // forward scattering: the rim of a block is where the most light gets through
   float glow = pow(clamp(lightDot, 0.0, 1.0), 8.0);
   float edge = cloudEdge(texUV);

   cloudColor += lightColor * glow * (0.3 + 0.7 * edge) * CLOUD_SILVER_LINING * clearSky;

   cloudColor *= 1.0 - rainStrength * CLOUD_WEATHER_DARKNESS;

   // no tonemapper behind this pass: rolling the peak back to 1.0 keeps the hue
   // where it would otherwise clip to white
   float peak = max(cloudColor.r, max(cloudColor.g, cloudColor.b));
   cloudColor /= max(peak, 1.0);

   // the alpha has to fade too, or a far cloud turns into a grey slab of fog
   // colour
   cloudColor = mix(cloudColor, fogColor, fogMix);

   /* DRAWBUFFERS:06 */
   gl_FragData[0] = vec4(cloudColor, albedo.a * color.a * (1.0 - fogMix));
   gl_FragData[1] = vec4(vec3(0.0), 1.0);
}
