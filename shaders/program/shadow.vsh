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

   // the biome tint never reaches the texture, it is applied on top of it, so
   // the colour of the block has to be carried over separately: for water and
   // for glass it is half of what makes the shadow the colour it should be
   blockColor = gl_Color.rgb;
}
