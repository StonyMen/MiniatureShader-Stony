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

   // gl_FragData[0] of the shadow pass is shadowcolor0. it stores the colour of
   // whatever casts the shadow here, and only the translucent pass is ever read
   // back from it: an opaque caster is recognised through shadowtex1, so the
   // colour it leaves in this buffer is never used. because the translucent
   // geometry is drawn last and still depth tests, this ends up holding the
   // colour of the nearest caster, which is exactly the one being looked at
   gl_FragData[0] = vec4(albedo.rgb * blockColor, albedo.a);
}
