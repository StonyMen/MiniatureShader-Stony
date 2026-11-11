#define LIGHT_BRIGHTNESS 0.8 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]

#define ENABLE_FOG
#define OVERWORLD_FOG_MAX_SLIDER 5 //[0 1 2 3 4 5 6 7 8 9 10]
#define OVERWORLD_FOG_MIN_SLIDER 2 //[0 1 2 3 4 5 6 7 8 9 10]
#define WEATHER_OPACITY 0.5 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

// reflections are per surface, on a 0-10 scale: BLOCK_REFLECTIONS is baked into
// each block's reflectivity in textured_lit.fsh, WATER_REFLECTION_STRENGTH is
// applied in final.fsh. 0 disables both the value and the trace
#define BLOCK_REFLECTIONS 5          //[0 1 2 3 4 5 6 7 8 9 10]
#define WATER_REFLECTION_STRENGTH 5  //[0 1 2 3 4 5 6 7 8 9 10]
#define SSR_MAX_STEPS 10     //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 20 24 32 64 96 128 256 512]
#define SSR_STEP_SIZE 1.5    //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SSR_BINARY_STEPS 4   //[1 2 3 4 5 6 7 8 9 10]

#define SHADOW_PIXEL 16     //[0 4 8 16 32 64 128 256 512 1024 2048]

// translucent casters (glass, water, ice): 0 = none, 1 = grey shadow,
// 2 = the block's own colour. 1 and 2 cost two extra shadow map lookups
#define COLORED_SHADOWS 1 //[0 1 2]

const int   shadowMapResolution = 1024;  //[256 512 1024 2048 3072 4096]
const float shadowDistance      = 128.0; //[8.0 16.0 32.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 1024.0]
// fixed at the Iris default: no allowed-value list, so it stays out of the menu
const float shadowIntervalSize  = 2.0;
const float shadowDistanceRenderMul = 1.0;
const float entityShadowDistanceMul = 0.25; //[0.125 0.2 0.25 0.333 0.5 0.75 1.0]
const float sunPathRotation = -30.0; //[-90.0 -85.0 -80.0 -75.0 -70.0 -65.0 -60.0 -55.0 -50.0 -45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0]

#define WATER_WAVE_SIZE 1          //[0 1 2 3 4 5 6 7 8 9 10]
#define WATER_WAVE_SPEED 2         //[1 2 3 4 5 6 7 8 9 10]
#define WATER_BRIGHTNESS 0.5       //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define WATER_SATURATION 0.8       //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define WATER_A 0.8                //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define WATER_MIN_GLINT 8          //[-1 0 1 2 3 4 5 6 7 8 9 10]
#define WATER_GLINT_CUTOFF 0.6     //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define WATER_GLINT_BRIGHTNESS 0.8 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]

// the cloud geometry is vanilla, these options only shade it: the layer is a
// slab of CLOUD_THICKNESS blocks starting at CLOUD_HEIGHT, which is what tells
// a cloud's top face from its bottom one
#define CLOUD_LIGHT_GAIN 0.5        //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5]
#define CLOUD_SILVER_LINING 0.5     //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define CLOUD_WEATHER_DARKNESS 0.15 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

#define CLOUD_HEIGHT 192.0
#define CLOUD_THICKNESS 4.0

#define END_STARS_SPEED  0.01  //[0.002 0.005 0.01 0.02 0.05 0.1 0.5]
#define END_STARS_AMOUNT 128.0 //[128.0 256.0 512.0 1024.0 2048.0]
#define END_STARS_FLOOR  256.0
#define END_STARS_OPACITY 0.5 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define FLAT_LIGHTING
#define GLOWING_ORES
#define SHADOW_ENTITY 1 //[-1 0 1]
#define ENABLE_SKY
#define NETHER_COLOR_GRADING
#define END_PORTAL

#ifdef OVERWORLD
   #define ENABLE_SHADOWS
#endif

// -1 = off, 0 = only while holding a light, 1 = always
#define HAND_DYNAMIC_LIGHTING 0 //[-1 0 1]

// empty #ifdef blocks: optifine only lists an option when its define is used
#ifdef ENABLE_FOG
#endif
#ifdef ENABLE_SKY
#endif
#ifdef FLAT_LIGHTING
#endif
#ifdef SHADOW_ENTITY
#endif
#ifdef NETHER_COLOR_GRADING
#endif

//----------------------------------------------------------------------------//

#define MIN_REFLECTIVITY 0.01
#define WATER_REFLECTIVITY 0.99
#define GLASS_REFLECTIVITY 0.3

#define HALF_PI 1.570796326
#define PI 3.141592653
#define SQRT_2 1.414213562
#define SUNSET 0.5325 // 12780
#define MIDNIGHT 0.75 // 18000
#define SUNRISE 0.9675 // 23220

const float NORMALIZE_TIME = 1.0/24000.0;

const float OVERWORLD_FOG_MIN = 1.0 - 0.1*OVERWORLD_FOG_MAX_SLIDER;
const float OVERWORLD_FOG_MAX = 1.0 - 0.1*OVERWORLD_FOG_MIN_SLIDER;

const vec2 AMBIENT_UV = vec2(8.0/255.0, 247.0/255.0);
const vec2 TORCH_UV_SCALE = vec2(8.0/255.0, 231.0/255.0);

// fixed look values (colour constants without a menu option) live at their use
// site, marked "fixed look value": torch rings, moon colour, translucent shadow
// strength, shadow tint, end ambient, end star decay, sunset cloud warmth

const float SHADOW_MAX_DIST_SQUARED = shadowDistance * shadowDistance;
const float INV_SHADOW_MAX_DIST_SQUARED = 1.0/SHADOW_MAX_DIST_SQUARED;