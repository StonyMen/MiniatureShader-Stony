attribute vec4 mc_Entity;

varying vec2 texUV;
varying float alpha;
varying vec3 blockColor;

#include "/common/getShadowDistortion.glsl"

void main() {
   gl_Position = ftransform();
   gl_Position.xyz = getShadowDistortion(gl_Position.xyz);

   texUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
   alpha = mc_Entity.x == 10072.0 ? 0.0 : gl_Color.a;

   // the biome tint never reaches the texture, so the block colour is carried
   // over separately
   blockColor = gl_Color.rgb;
}
