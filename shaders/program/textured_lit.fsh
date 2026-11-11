#include "/shader.h"

uniform float screenBrightness;
uniform int entityId;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform vec4 entityColor;
uniform float frameTimeCounter;

// transformations.glsl declares this too, but only when shadows are on
#ifndef ENABLE_SHADOWS
   uniform vec3 cameraPosition;
#endif

// vanilla's per layer palette, straight from rendertype_end_portal. PORTAL_BASE
// stands in for its first sampler (end_sky x COLORS[0]), which this program
// cannot bind: it is the average of that product
const vec3 PORTAL_BASE = vec3(0.010, 0.034, 0.068);

const vec3 PORTAL_COLORS[16] = vec3[16](
   vec3(0.022087, 0.098399, 0.110818), vec3(0.011892, 0.095924, 0.089485),
   vec3(0.027636, 0.101689, 0.100326), vec3(0.046564, 0.109883, 0.114838),
   vec3(0.064901, 0.117696, 0.097189), vec3(0.063761, 0.086895, 0.123646),
   vec3(0.084817, 0.111994, 0.166380), vec3(0.097489, 0.154120, 0.091064),
   vec3(0.106152, 0.131144, 0.195191), vec3(0.097721, 0.110188, 0.187229),
   vec3(0.133516, 0.138278, 0.148582), vec3(0.070006, 0.243332, 0.235792),
   vec3(0.196766, 0.142899, 0.214696), vec3(0.047281, 0.315338, 0.321970),
   vec3(0.204675, 0.390010, 0.302066), vec3(0.080955, 0.314821, 0.661491)
);

// only the improved path reprojects the pattern; vanilla reads the screen
#ifndef END_PORTAL
   uniform float viewWidth;
   uniform float viewHeight;
#endif

flat varying float lightSourceLevel;
varying float fogMix;
varying float sunHeight;
varying vec2 lightUV;
varying vec2 texUV;
varying vec3 feetPos;
varying vec3 gradientFogColor;

#ifdef GBUFFERS_TERRAIN
   varying vec4 color;
#else
   flat varying vec4 color;
#endif

#ifdef THE_END
   varying vec3 endTint;
#endif

#if BLOCK_REFLECTIONS > 0
   flat varying vec3 blockReflectivity;
   varying vec3 normal;
#endif

#ifdef GLOWING_ORES
   flat varying float isOre;
#endif

#if HAND_DYNAMIC_LIGHTING == 0
   uniform int heldBlockLightValue;
#elif HAND_DYNAMIC_LIGHTING == 1
   #define heldBlockLightValue 14
#endif

#include "/common/math.glsl"
#include "/common/getTorchColor.fsh"
#include "/common/getAmbientColor.glsl"

#ifdef ENABLE_SHADOWS
   uniform mat4 shadowModelView;
   uniform mat4 shadowProjection;
   uniform sampler2D shadowtex1;

   // mode 0 never reads the translucent layer, so do not even bind it
   #if COLORED_SHADOWS > 0
      uniform sampler2D shadowtex0;
      uniform sampler2D shadowcolor0;
   #endif

   varying vec3 lightColor;
   varying float diffuse;

   #include "/common/transformations.glsl"
   #include "/common/getLightStrength.fsh"
#endif

void main() {
   #ifdef END_PORTAL
   // cross of the world space derivatives gives the normal of whatever face this
   // fragment belongs to, without spending a varying on it
   vec3 faceNormal = abs(cross(dFdx(feetPos), dFdy(feetPos)));
   #endif

   // end portal and gateway: Iris draws both as entitySolid(end_portal.png) with a
   // 0.2 wide uv window and a flat 0.075/0.15/0.2 vertex colour, so the generic
   // path below would shade them like a dark block. either way they are drawn
   // here and never reach the lighting below
   float portalTint = length(color.rgb);

   if (portalTint > 0.001 && portalTint < 0.3
    && dot(color.rgb / portalTint, vec3(0.2873, 0.5746, 0.7661)) > 0.9995) {
      #ifdef END_PORTAL
      // Iris gives every face the same 0..0.2 window, so neighbouring blocks
      // repeat instead of joining up. rebuild the coordinate from world
      // position on the face plane, which coplanar faces then share. 1/12 per
      // block is vanilla's texel density magnified four times - raise the
      // divisor for smaller stars, lower it for bigger ones
      vec3 worldPos = feetPos + cameraPosition;

      vec2 base = (faceNormal.z > max(faceNormal.x, faceNormal.y) ? worldPos.xy
                : faceNormal.x > faceNormal.y ? worldPos.zy : worldPos.xz) * (1.0/12.0);
      #else
      // vanilla's texProj0 is the screen position, so the same layer stack keeps
      // its camera locked look and no block can seam
      vec2 base = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
      #endif

      vec3 portal = PORTAL_BASE;

      for (int i = 0; i < 15; i++) {
         float layer = float(i + 1);
         float angle = radians((layer*layer*4321.0 + layer*9.0) * 2.0);
         float zoom = 4.5 - layer/4.0;
         float drift = (2.0 + layer/1.5) * frameTimeCounter * 0.00125;

         // vanilla feeds the layer matrix a row vector, so rotate and scale come
         // first and the offset lands on top in unrotated texture space. that is
         // what makes every layer drift in its own direction - keep the addition
         // outside the rotation
         vec2 pos = mat2(cos(angle), sin(angle), -sin(angle), cos(angle)) * base * zoom
                  + vec2(8.5/layer, 0.5*drift) + 0.25;

         portal += texture2D(gtexture, fract(pos)).rgb * PORTAL_COLORS[i];
      }

      gl_FragData[0] = vec4(portal, 1.0);
      gl_FragData[1] = vec4(vec3(0.0), 1.0);
      gl_FragData[2] = vec4(vec3(0.0), 1.0);

      return;
   }

   if (fogMix > 0.999) {
      discard;
   }

   vec4 albedo = texture2D(gtexture, texUV);
   vec4 color  = color;

   #ifdef GBUFFERS_TERRAIN
      float ambientOcclusion = color.a;
      color.a = 1.0;
   #else
      float ambientOcclusion = 1.0;
   #endif

   #ifdef MOD_COLORWHEEL
      vec2 lightUV;
      vec4 entityColor;

      clrwl_computeFragment(albedo, albedo, lightUV, ambientOcclusion, entityColor);
   #endif

   vec4 ambient = getAmbientColor(lightUV.t, sunHeight);

   #ifdef THE_END
      ambient.rgb *= endTint;
   #endif

   #ifdef GLOWING_ORES
      ambient.rgb = mix(
         ambient.rgb,
         vec3(1.0, 0.9, 0.9),
         isOre * 0.3333*squaredLength(rescale(albedo.rgb, vec3(0.59), vec3(1.0)))
      );
   #endif

   albedo *= color;

   // render thunder
   albedo.a = entityId == 11000.0 ? 0.15 : albedo.a;
   // render entity color changes (e.g taking damage)
   albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);

   float albedoLuma = luma(albedo.rgb);

   #ifdef ENABLE_SHADOWS
      // a colour, not a number: tinting and shadowing are the same operation
      vec3 lightStrength = getLightStrength(diffuse, lightUV.t, feetPos);
      float lightBrightness = max(0.0, LIGHT_BRIGHTNESS - 0.5*pow3(albedoLuma));

      lightStrength = max(lightStrength, 0.75*lightSourceLevel);

      // fixed look value: shadow tint - raise g/b for bluer shadows, 1.0 for none
      ambient.rgb *= mix(vec3(1.0, 1.06666, 1.2), vec3(1.0), lightStrength);
      ambient.rgb *= 0.75 + (lightBrightness * lightStrength) * lightColor;
   #endif

   ambient.rgb += getTorchColor(lightUV.s, ambient.rgb, feetPos);

   albedo.rgb *= ambientOcclusion;

   albedo *= ambient;

   #if defined THE_NETHER && defined NETHER_COLOR_GRADING
      albedo.rgb = mix(
         vec3(luma(albedo.rgb)),
         albedo.rgb,
         max(rescale(luma(ambient.rgb), 0.2, 0.6), rescale(albedoLuma, 0.15, 0.4))
      );
   #endif

   albedo.rgb = mix(albedo.rgb, gradientFogColor, fogMix);

   /* DRAWBUFFERS:067 */
   gl_FragData[0] = albedo;

   #if BLOCK_REFLECTIONS > 0
      float reflectivity = max(0.0, (albedoLuma - blockReflectivity.y) * blockReflectivity.x * 0.2*BLOCK_REFLECTIONS);

      gl_FragData[1] = vec4(normal, 1.0);
      gl_FragData[2] = vec4(reflectivity, blockReflectivity.z, 0.5, 1.0);
   #else
      gl_FragData[1] = vec4(vec3(0.0), 1.0);
      gl_FragData[2] = vec4(vec3(0.0), 1.0);
   #endif
}