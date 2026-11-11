float random(vec2 v) {
	return fract(sin(dot(v, vec2(18.9898, 28.633))) * 4378.5453);
}

vec3 random3(vec3 v) {
   v = fract(v * vec3(0.3183099, 0.3678794, 0.7071068)); // 1/π, 1/e, 1/√2
   v += dot(v, v.yzx + 19.19);

   return fract(vec3(v.x * v.y * 95.4307,
                     v.y * v.z * 97.5901,
                     v.z * v.x * 93.8365)) - 0.5;
}

float luma(vec3 color) {
   return dot(vec3(0.299, 0.587, 0.114), color);
}

float rescale(float x, float a, float b) {
   return clamp((x - a) / (b - a), 0.0, 1.0);
}

vec3 rescale(vec3 x, vec3 a, vec3 b) {
   return clamp((x - a) / (b - a), vec3(0.0), vec3(1.0));
}

float round(float x) {
   return floor(x + 0.5);
}

vec3 round(vec3 x) {
   return floor(x + 0.5);
}

float squaredLength(vec3 v) {
   return dot(v, v);
}

float stepify(float x, float stepSize) {
   return round(x / stepSize) * stepSize;
}

vec3 stepify(vec3 x, float stepSize) {
   return round(x / stepSize) * stepSize;
}

vec3 bandify(vec3 value, float bands) {
   return (floor(value*bands + 0.01) + 0.5) / bands;
}

float fogify(float x, float w) {
	return w / (x * x + w);
}

float smoothe(float x) {
   return x*x*(3.0 - 2.0*x);
}

float pow3(float x) {
   return x*x*x;
}

float slopeTo1(float x, float m) {
   return max(0.0, x*m - (m - 1.0));
}
