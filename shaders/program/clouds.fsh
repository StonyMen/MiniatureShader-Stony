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

// one texel of the cloud texture is one cloud block, so a neighbour with an
// empty alpha means this fragment sits on the edge of a block
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

   // the alpha channel is the shape of the cells: keep the edge hard, a soft
   // one is what makes clouds look like fog instead of blocks. the threshold
   // stays low on purpose, the mipmaps of the cloud texture blur the alpha at
   // distance and dropping those fragments would punch holes in far clouds
   if (albedo.a < 0.1) {
      discard;
   }

   vec3 dir     = normalize(viewDir);
   vec3 sunDir  = normalize(sunPosition);
   vec3 moonDir = normalize(moonPosition);

   // the moon takes over once the sun is down, exactly like the vanilla light
   float lightDot = max(dot(dir, sunDir), dot(dir, moonDir));

   // how low the sun is decides how warm its light is: white overhead, orange
   // on the horizon and no warmth at all during the night
   float sunHeight = (mat3(gbufferModelViewInverse) * sunDir).y;
   float warmth = (1.0 - rescale(sunHeight, 0.0, 0.35))
                * smoothstep(-0.1, 0.05, sunHeight);

   vec3 lightColor = mix(vec3(1.0), vec3(1.0, 0.58, 0.36), warmth * CLOUD_SUN_TINT);

   // rain and thunder put a lid on the sky: there is no sun to reach the clouds
   // any more, so they stop reacting to it and keep their flat vanilla colour
   // until the weather clears up again
   float clearSky = 1.0 - rainStrength;

   // how much of that light a fragment catches, 0 to 1: the side of the cloud
   // turned towards the sun gets all of it, and the underside less than the
   // top because it looks away from the sky
   float exposure = clamp(lightDot, 0.0, 1.0) * mix(0.6, 1.0, cloudTopness) * clearSky;

   // the vanilla colour is the baseline and the light is only added on top of
   // it, so a cloud that catches no light looks exactly like it does without
   // the shader and only the lit part is pushed above it
   vec3 cloudColor = albedo.rgb * color.rgb
                   * (1.0 + CLOUD_LIGHT_GAIN * exposure * lightColor);

   // forward scattering: looking through a cloud towards the sun lights it up
   // from the inside, and the rim of a block is where the most light gets
   // through, so the edge is brightened on top of the flat faces
   float glow = pow(clamp(lightDot, 0.0, 1.0), 8.0);
   float edge = cloudEdge(texUV);

   cloudColor += lightColor * glow * (0.3 + 0.7 * edge) * CLOUD_SILVER_LINING * clearSky;

   cloudColor *= 1.0 - rainStrength * CLOUD_WEATHER_DARKNESS;

   // the distance is measured in the vertex shader already, and it has to be
   // applied to the alpha as well: a cloud that is far enough has to dissolve
   // into the sky instead of turning into a grey slab of fog colour
   cloudColor = mix(cloudColor, fogColor, fogMix);

   /* DRAWBUFFERS:06 */
   gl_FragData[0] = vec4(cloudColor, albedo.a * color.a * (1.0 - fogMix));
   gl_FragData[1] = vec4(vec3(0.0), 1.0);
}
