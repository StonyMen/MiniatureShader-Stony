//----------------------------------------------------------------------------//
// clouds
//
// vanilla draws the clouds after the translucent geometry and they are culled
// by the depth of the water and the stained glass, which is the bug that the
// "improved transparency" option works around. the cloud layer is therefore
// raymarched here instead of being rendered as geometry: it is sampled in
// world space and composited on top of the opaque scene but below the
// translucent geometry (see final.fsh), so it can never be culled by it.
//
// the layer is a slab of CLOUD_THICKNESS blocks, the shape comes from the
// vanilla cloud texture (one texel per cloud cell), which is sampled as a
// hard mask, so the cells are plain square blocks without any rounding
//----------------------------------------------------------------------------//

uniform sampler2D colortex1; // minecraft:textures/environment/clouds.png
uniform int worldTime;
uniform vec3 sunPosition;
// fogColor is declared by the program that includes this file (final.fsh)

float getCloudMask(vec2 cell) {
   vec2 uv = fract((cell + 0.5) / CLOUD_TEXTURE_SIZE);

   return step(0.5, texture2D(colortex1, uv).r);
}

// origin is the ray start point (eye or water surface) in feet space
// dir is the normalized ray direction, world aligned
// sceneDistance is the distance of the opaque geometry along the ray
// tint is the color the clouds take their lighting from (the sky behind them)
vec4 getClouds(vec3 origin, vec3 dir, float sceneDistance, vec3 tint) {
   float bottom = CLOUD_HEIGHT - cameraPosition.y;
   float top    = bottom + CLOUD_THICKNESS;

   // the part of the ray which is inside the cloud layer
   float t0, t1;

   if (abs(dir.y) < 0.00001) {
      if (origin.y < bottom || origin.y > top) return vec4(0.0);

      t0 = 0.0;
      t1 = CLOUD_DIST;
   } else {
      float a = (bottom - origin.y) / dir.y;
      float b = (top    - origin.y) / dir.y;

      t0 = max(min(a, b), 0.0);
      t1 = max(a, b);
   }

   t1 = min(t1, min(CLOUD_DIST, sceneDistance));

   if (t1 <= t0) return vec4(0.0);

   // the layer is a grid of CLOUD_CELL_SIZE blocks and drifts westwards
   vec2 pos = (origin + dir * t0).xz
            + cameraPosition.xz
            + vec2(float(worldTime) * CLOUD_DRIFT, 0.0);

   // grid walk, one step per cloud cell (a 2D DDA)
   vec2  cell   = floor(pos / CLOUD_CELL_SIZE);
   float stepX  = dir.x > 0.0 ? 1.0 : -1.0;
   float stepZ  = dir.z > 0.0 ? 1.0 : -1.0;
   float deltaX = abs(dir.x) > 0.00001 ? CLOUD_CELL_SIZE / abs(dir.x) : 1e9;
   float deltaZ = abs(dir.z) > 0.00001 ? CLOUD_CELL_SIZE / abs(dir.z) : 1e9;
   float maxX   = abs(dir.x) > 0.00001 ? ((cell.x + max(stepX, 0.0)) * CLOUD_CELL_SIZE - pos.x) / dir.x : 1e9;
   float maxZ   = abs(dir.z) > 0.00001 ? ((cell.y + max(stepZ, 0.0)) * CLOUD_CELL_SIZE - pos.y) / dir.z : 1e9;

   float hit = -1.0;
   float t   = 0.0;

   // the normal of the face the ray enters the cell through. a ray coming from
   // above enters through the top face of the layer and one coming from below
   // through its bottom face, every step in x or z instead enters the next cell
   // through one of its sides
   vec3 normal = vec3(0.0, dir.y < 0.0 ? 1.0 : -1.0, 0.0);

   for (int i = 0; i < CLOUD_STEPS; i++) {
      if (getCloudMask(cell) > 0.5) {
         hit = t;
         break;
      }

      if (maxX < maxZ) {
         t      = maxX;
         maxX  += deltaX;
         cell.x += stepX;
         normal = vec3(-stepX, 0.0, 0.0);
      } else {
         t      = maxZ;
         maxZ  += deltaZ;
         cell.y += stepZ;
         normal = vec3(0.0, 0.0, -stepZ);
      }

      if (t > t1 - t0) break;
   }

   if (hit < 0.0) return vec4(0.0);

   float dist = t0 + hit;

   vec3 sunDir = normalize(view2eye(sunPosition));

   // the cells are lit like the faces of a box: the top face is the brightest
   // and the bottom the darkest, the sides in between with a slight preference
   // for the ones facing the sun. without this every cell gets the same color
   // and the whole layer looks like a flat sheet of tiles
   float shade;

   if (normal.y > 0.5) {
      shade = CLOUD_TOP_SHADE;
   } else if (normal.y < -0.5) {
      shade = CLOUD_BOTTOM_SHADE;
   } else {
      vec3  sunFlat = vec3(sunDir.x, 0.0, sunDir.z) + vec3(1e-4, 0.0, 1e-4);
      float lit     = dot(normal, normalize(sunFlat));

      shade = CLOUD_SIDE_SHADE * (1.0 + CLOUD_SIDE_SUN * lit);
   }

   // the clouds take their lighting from the sky behind them, desaturated and
   // brightened a bit, so they stay dark at night and warm at sunset
   float lum  = luma(tint);
   vec3  base = mix(tint, vec3(lum), 0.45) * 1.75;

   // the sky goes black at night, so a bit of light is added back to keep the
   // clouds readable without making them glow in the dark
   base += CLOUD_NIGHT_LIGHT * (1.0 - clamp(lum / 0.12, 0.0, 1.0));

   vec3 color = base * shade;

   // forward scattering when looking towards the sun
   float sunCloseness = max(dot(dir, sunDir), 0.0);
   color *= 1.0 + 0.5 * pow(sunCloseness, 8.0);

   float fog = rescale(dist, 0.65 * CLOUD_DIST, CLOUD_DIST);
   color = mix(color, fogColor, fog);

   // premultiplied
   return vec4(color * (1.0 - fog), 1.0 - fog);
}
