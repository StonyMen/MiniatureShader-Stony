uniform sampler2D gtexture;

varying vec2 texUV;
varying float alpha;
varying vec3 blockColor;

void main() {
   vec4 albedo = texture2D(gtexture, texUV);

   albedo.a *= alpha;

   if (albedo.a < 0.1) {
      discard;
   }

   // gl_FragData[0] is shadowcolor0: only the translucent pass reads it back, so
   // it ends up holding the colour of the nearest translucent caster
   gl_FragData[0] = vec4(albedo.rgb * blockColor, albedo.a);
}
