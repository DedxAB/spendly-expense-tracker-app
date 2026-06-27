// -----------------------------------------------------------------------------
// Gradient-method selector for the SINGLE-LENS shaders (liquid_glass + border).
// #include this BEFORE liquid_glass_common.glsl, which applies GLASS_GRAD_METHOD.
// -----------------------------------------------------------------------------
#ifndef LIQUID_GLASS_GRAD_SELECT_GLSL
#define LIQUID_GLASS_GRAD_SELECT_GLSL

// Internal flag. 1 = BOTH backends use the 5-tap central difference (exact for
// every corner style, ~5x SDF cost). 0 = each backend picks its cheapest method.
#ifndef LIQUID_GLASS_FORCE_5TAP
#define LIQUID_GLASS_FORCE_5TAP 0
#endif

// Raw values (the named GLASS_GRAD_* constants live in common.glsl, not yet
// included): 0 = derivative (Impeller), 1 = analytic (Skia), 2 = 5-tap.
#ifndef GLASS_GRAD_METHOD
#if LIQUID_GLASS_FORCE_5TAP
#define GLASS_GRAD_METHOD 2
#elif defined(LIQUID_GLASS_SKIA)
#define GLASS_GRAD_METHOD 1
#else
#define GLASS_GRAD_METHOD 0
#endif
#endif

#endif
