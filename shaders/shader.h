#define LIGHT_BRIGHTNESS 0.8 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]

#define ENABLE_FOG
#define OVERWORLD_FOG_MAX_SLIDER 5 //[0 1 2 3 4 5 6 7 8 9 10]
#define OVERWORLD_FOG_MIN_SLIDER 2 //[0 1 2 3 4 5 6 7 8 9 10]
#define WEATHER_OPACITY 0.5 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

// the reflections are controlled per surface, there is no global opacity
// anymore: the blocks scale their own reflectivity in textured_lit.fsh, the
// water is scaled in final.fsh, both on the same 0-10 scale (10 = full)
// these four values, together with the shadow settings below, are the MEDIUM
// profile of shaders.properties - keep the two in sync
#define BLOCK_REFLECTIONS 5          //[0 1 2 3 4 5 6 7 8 9 10]
#define WATER_REFLECTION_STRENGTH 5  //[0 1 2 3 4 5 6 7 8 9 10]
#define SSR_MAX_STEPS 10     //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 20 24 32 64 96 128 256 512]
#define SSR_STEP_SIZE 1.5    //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SSR_BINARY_STEPS 4   //[1 2 3 4 5 6 7 8 9 10]

#define SHADOW_PIXEL 16     //[0 4 8 16 32 64 128 256 512 1024 2048]

// translucent casters (glass, water and ice) have three modes:
//   0 = do not render them at all, only opaque geometry casts a shadow
//   1 = render them, but as a neutral grey filter: the shadow is as deep as
//       the material is opaque and carries no colour from the block
//   2 = render them with the block's own colour, as deep as it is opaque
// modes 1 and 2 both cost two extra shadow map lookups per pixel. each profile
// picks one of the three: LOW 0, MEDIUM 1 (also the default here), HIGH 2
#define COLORED_SHADOWS 1 //[0 1 2]

const int   shadowMapResolution = 1024;  //[256 512 1024 2048 3072 4096]
const float shadowDistance      = 128.0; //[8.0 16.0 32.0 64.0 96.0 128.0 192.0 256.0 384.0 512.0 1024.0]
// fixed at 2 blocks (Iris default): snapping removes shadow shimmer regardless
// of the interval, and a small one keeps the player near the distortion focus.
// no allowed-value list, so the option stays out of the settings menu
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

// the clouds are still the vanilla ones: vanilla builds the geometry out of
// the cloud texture, these options only change how it is shaded. the layer is
// a slab of CLOUD_THICKNESS blocks starting at CLOUD_HEIGHT, which is what
// tells a cloud's top face from its bottom one
#define CLOUD_SUN_TINT 0.6          //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
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

#ifdef OVERWORLD
   #define ENABLE_SHADOWS
#endif

#if MC_VERSION >= 11300
   #define HAND_DYNAMIC_LIGHTING 0 //[-1 0 1]
#endif

// optifine needs these to show on menu
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
#define TAU 6.283185307
#define SQRT_2 1.414213562
#define NOON 0.25 // 6000
#define SUNSET 0.5325 // 12780
#define MIDNIGHT 0.75 // 18000
#define SUNRISE 0.9675 // 23220

const float INV_PI = 1.0 / PI;
const float INV_TAU = 1.0 / TAU;

const float NORMALIZE_TIME = 1.0/24000.0;

const float OVERWORLD_FOG_MIN = 1.0 - 0.1*OVERWORLD_FOG_MAX_SLIDER;
const float OVERWORLD_FOG_MAX = 1.0 - 0.1*OVERWORLD_FOG_MIN_SLIDER;

const vec2 AMBIENT_UV = vec2(8.0/255.0, 247.0/255.0);
const vec2 TORCH_UV_SCALE = vec2(8.0/255.0, 231.0/255.0);

// the torch rings, the moon colour and the shadow tint (darkness + blueness)
// used to be menu sliders. they are fixed constants now: they define the look
// of the pack, so change them here in shader.h rather than in the options screen
const vec3 TORCH_INNER_COLOR   = vec3(1.0, 0.85, 0.7);
const vec3 TORCH_MIDDLE_COLOR  = vec3(1.0, 0.8,  0.6);
const vec3 TORCH_OUTER_COLOR   = vec3(1.0, 0.55, 0.2);
const vec3 MOON_COLOR          = vec3(0.1, 0.15, 0.3);
const float SHADOW_DARKNESS    = 0.0;
const float SHADOW_BLUENESS    = 0.2;

const vec4 END_STARS_DRAG = vec4(200, 500, 100, 100);
const vec3 END_AMBIENT    = vec3(0.83, 0.7, 1.0);

const vec3 SHADOW_COLOR = vec3(1.0 - SHADOW_DARKNESS) + vec3(0.0, 0.3333, 1.0) * SHADOW_BLUENESS;

// a translucent block does not block the light, it filters it: what reaches the
// ground is the colour of the block, dimmed by this. mode 2 uses that colour,
// mode 1 only its luminance, so both darken by the same amount and only mode 2
// tints. 0 would turn translucent blocks into fully opaque casters, 1 would let
// the same amount of light through as comes in. this is the value for a fully
// opaque pixel - a transparent one scales the shadow down by its own alpha
// first, so a water surface throws a fainter shadow than a glass frame
const float SHADOW_TRANSLUCENT_STRENGTH = 0.55;

const float SHADOW_MAX_DIST_SQUARED = shadowDistance * shadowDistance;
const float INV_SHADOW_MAX_DIST_SQUARED = 1.0/SHADOW_MAX_DIST_SQUARED;