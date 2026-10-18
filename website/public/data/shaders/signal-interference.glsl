// GhostFX — Signal Interference (signal-interference) v1.0.0
// Electronic interference: wavy horizontal distortion, tinted noise bars and brief signal dropouts.
// Category: glitch | Mode: post | Preset: balanced
// Source: shaders/glitch/signal-interference.glsl | Built by ghostfx 0.9.0
// License: MIT | https://github.com/r3dg0d/ghostfx
// Generated file: edit the source and rebuild instead.
// Requires Ghostty >= 1.3

#define GFX_INTENSITY 0.6
#define GFX_SPEED 1.0
#define GFX_BRIGHTNESS 1.0
#define GFX_SATURATION 1.0
#define GFX_OPACITY 1.0
#define GFX_READABILITY 0.7
#define GFX_REDUCED_MOTION 0.0
#define GFX_REDUCED_FLASH 0.0
#define GFX_DISTORT_TEXT 1.0
#define GFX_QUALITY 1
#define GFX_COLORSPACE 0
#define GFX_COLORSPACE_FALLBACK 2
#define P_WAVE 1.0
#define P_BARS 0.6
#define GFX_PRIMARY vec3(0.5451, 0.3608, 0.9647)
#define GFX_SECONDARY vec3(0.2980, 0.1137, 0.5843)
#define GFX_ACCENT vec3(0.7529, 0.5176, 0.9882)
#define GFX_BACKGROUND vec3(0.0431, 0.0392, 0.0627)
#define GFX_FOREGROUND vec3(0.9020, 0.8902, 0.9412)

// GhostFX core compatibility layer.
//
// Translates GhostFX conventions onto the real Ghostty custom-shader
// interface (see docs/GHOSTTY_SHADER_API.md). Every built shader includes
// this module. All GFX_* parameters are injected as #defines by the build
// tool (tools/ghostfx/build.py) before this file.

#define GFX_PI  3.14159265359
#define GFX_TAU 6.28318530718

// Ghostty >= 1.3 exposes the terminal colors as uniforms. Older releases do
// not, so legacy builds fall back to the palette colors from the preset.
// Focus uniforms also arrived in 1.3; legacy builds behave as always focused.
#ifdef GFX_LEGACY
#define GFX_TERM_BG GFX_BACKGROUND
#define GFX_TERM_FG GFX_FOREGROUND
#define GFX_TIME_FOCUS 0.0
#define GFX_FOCUSED 1
#else
#define GFX_TERM_BG iBackgroundColor
#define GFX_TERM_FG iForegroundColor
#define GFX_TIME_FOCUS iTimeFocus
#define GFX_FOCUSED iFocus
#endif

// Quality-dependent loop counts. GFX_QUALITY: 0 = eco, 1 = balanced, 2 = ultra.
#if GFX_QUALITY == 0
#define GFX_OCTAVES 3
#define GFX_STEPS   24
#define GFX_LAYERS  3
#elif GFX_QUALITY == 1
#define GFX_OCTAVES 5
#define GFX_STEPS   48
#define GFX_LAYERS  5
#else
#define GFX_OCTAVES 6
#define GFX_STEPS   80
#define GFX_LAYERS  7
#endif

// ---------------------------------------------------------------------------
// Time
// ---------------------------------------------------------------------------

// Animation time in seconds, scaled by speed and the reduced-motion switch.
// iTime is wrapped every two hours to keep float precision for long sessions.
float gfx_time() {
    float m = GFX_REDUCED_MOTION > 0.5 ? 0.2 : 1.0;
    return mod(iTime, 7200.0) * GFX_SPEED * m;
}

// Scale applied to anything that flashes or strobes.
float gfx_flash(float f) {
    return f * (GFX_REDUCED_FLASH > 0.5 ? 0.2 : 1.0);
}

// ---------------------------------------------------------------------------
// Coordinates
// ---------------------------------------------------------------------------

// 0..1 texture coordinates for iChannel0.
vec2 gfx_uv(vec2 fc) { return fc / iResolution.xy; }

// Aspect-corrected coordinates centred on the screen; y spans [-0.5, 0.5].
// Wider windows (ultrawide) simply reveal more of the x axis.
vec2 gfx_p(vec2 fc) { return (fc - 0.5 * iResolution.xy) / iResolution.y; }

float gfx_aspect() { return iResolution.x / iResolution.y; }

// Size of one physical pixel in gfx_p units (resolution independent AA).
float gfx_pxsize() { return 1.0 / iResolution.y; }

// UI scale relative to a 1440p-tall surface, for pixel-sized features.
float gfx_dpi() { return max(iResolution.y / 1440.0, 0.35); }

mat2 gfx_rot(float a) { float c = cos(a), s = sin(a); return mat2(c, s, -s, c); }

float gfx_luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

// ---------------------------------------------------------------------------
// Colour space
// ---------------------------------------------------------------------------
// With `alpha-blending = linear | linear-corrected` (Ghostty's default on
// Linux) iChannel0 holds linear colour and the output is sRGB-encoded by the
// framebuffer. With `native` (macOS default) everything is display-encoded.
// GhostFX works in display (sRGB) space, like iBackgroundColor and the
// palette uniforms, and converts at the edges.
// GFX_COLORSPACE: 0 = auto-detect, 1 = native, 2 = linear.

vec3 gfx_srgb_to_linear(vec3 c) {
    c = max(c, 0.0);
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

vec3 gfx_linear_to_srgb(vec3 c) {
    c = max(c, 0.0);
    return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c));
}

float gfx_lin_state = -1.0;

// Auto mode compares a few edge samples (usually padding/background) with
// the background colour in both encodings. Falls back to
// GFX_COLORSPACE_FALLBACK when the background is black/white (ambiguous).
bool gfx_is_linear() {
#if GFX_COLORSPACE == 1
    return false;
#elif GFX_COLORSPACE == 2
    return true;
#else
    if (gfx_lin_state < 0.0) {
        vec3 bs = GFX_TERM_BG;
        vec3 bl = gfx_srgb_to_linear(bs);
        gfx_lin_state = GFX_COLORSPACE_FALLBACK == 2 ? 1.0 : 0.0;
        if (distance(bs, bl) > 0.03) {
            vec2 e = 1.5 / iResolution.xy;
            float ds = 1e3, dl = 1e3;
            for (int i = 0; i < 5; i++) {
                vec2 q = i == 0 ? e : i == 1 ? vec2(1.0 - e.x, e.y) : i == 2 ? 1.0 - e
                       : i == 3 ? vec2(e.x, 1.0 - e.y) : vec2(0.5, e.y);
                vec4 t = texture(iChannel0, q);
                vec3 c = t.a > 0.004 ? t.rgb / t.a : vec3(-1.0);
                ds = min(ds, distance(c, bs));
                dl = min(dl, distance(c, bl));
            }
            if (min(ds, dl) < 0.03) gfx_lin_state = dl < ds ? 1.0 : 0.0;
        }
    }
    return gfx_lin_state > 0.5;
#endif
}

// Terminal sample in display space, premultiplied alpha.
vec4 gfx_term(vec2 uv) {
    vec4 t = texture(iChannel0, clamp(uv, 0.0, 1.0));
    if (gfx_is_linear() && t.a > 0.004) t.rgb = gfx_linear_to_srgb(t.rgb / t.a) * t.a;
    return t;
}

// ---------------------------------------------------------------------------
// Terminal sampling
// ---------------------------------------------------------------------------

// The terminal texture is premultiplied; return straight-alpha colour.
vec3 gfx_straight(vec4 t) {
    return t.a > 0.004 ? t.rgb / t.a : GFX_TERM_BG;
}

// 1.0 where a pixel differs from the terminal background (glyphs, cursor,
// coloured cells), 0.0 on plain background.
float gfx_text_mask(vec4 t) {
    vec3 bg = GFX_TERM_BG;
    float d = min(distance(t.rgb, bg), distance(t.rgb, bg * t.a));
    return smoothstep(0.035, 0.16, d);
}

// Dilated text mask (4 taps) used to keep a calm halo behind glyphs.
float gfx_text_halo(vec2 uv) {
    vec2 o = 2.5 * gfx_dpi() / iResolution.xy;
    float m = gfx_text_mask(gfx_term(uv + vec2(o.x, o.y)));
    m = max(m, gfx_text_mask(gfx_term(uv + vec2(-o.x, o.y))));
    m = max(m, gfx_text_mask(gfx_term(uv + vec2(o.x, -o.y))));
    m = max(m, gfx_text_mask(gfx_term(uv + vec2(-o.x, -o.y))));
    return m;
}

// ---------------------------------------------------------------------------
// Grading and readability
// ---------------------------------------------------------------------------

vec3 gfx_grade(vec3 c) {
    c *= GFX_BRIGHTNESS;
    float l = gfx_luma(c);
    return max(mix(vec3(l), c, GFX_SATURATION), 0.0);
}

// Keep effect luminance on the far side of the text colour: cap it for
// light-on-dark themes, lift it for dark-on-light themes.
vec3 gfx_readable(vec3 fx) {
    float r = GFX_READABILITY;
    if (r <= 0.0) return fx;
    float l = gfx_luma(fx);
    if (gfx_luma(GFX_TERM_FG) >= gfx_luma(GFX_TERM_BG)) {
        // Soft knee: untouched below 60% of the cap, compressed above it.
        // Compressed colours get a saturation boost so hot highlights stay
        // orange/cyan instead of turning muddy grey.
        float cap = mix(1.0, 0.3, r);
        float k = 0.6 * cap;
        if (l <= k) return fx;
        float l2 = k + (cap - k) * (1.0 - exp(-(l - k) / (cap - k)));
        vec3 c = fx * (l2 / l);
        float m = max(c.r, max(c.g, c.b));
        return m * pow(c / max(m, 1e-4), vec3(1.0 + 2.0 * (1.0 - l2 / l)));
    }
    float lo = mix(0.0, 0.62, r);
    return mix(fx, vec3(1.0), clamp((lo - l) / max(1.0 - l, 1e-4), 0.0, 1.0));
}

// Encode for the configured colour space and premultiply.
vec4 gfx_output(vec3 col, float a) {
    a = clamp(a, 0.0, 1.0);
    col = clamp(col, 0.0, 1.0);
    if (gfx_is_linear()) col = gfx_srgb_to_linear(col);
    return vec4(col * a, a);
}

// ---------------------------------------------------------------------------
// Compositing modes
// ---------------------------------------------------------------------------

// Background mode: the effect replaces the terminal background while glyphs
// and coloured cells stay on top, untouched.
vec4 gfx_compose(vec2 uv, vec4 term, vec3 fx) {
    float m = gfx_text_mask(term);
    vec3 base = gfx_straight(term);
    fx = gfx_readable(gfx_grade(fx));
#if GFX_QUALITY > 0
    if (GFX_READABILITY > 0.5) {
        fx *= 1.0 - 0.45 * (GFX_READABILITY - 0.5) * 2.0 * gfx_text_halo(uv) * (1.0 - m);
    }
#endif
    float k = GFX_INTENSITY;
    vec3 col = mix(mix(base, fx, k), base, m);
    float a = mix(mix(term.a, 1.0, k * GFX_OPACITY), max(term.a, m), m);
    return gfx_output(col, a);
}

// Overlay mode: light is added over everything, attenuated over glyphs.
vec4 gfx_overlay(vec2 uv, vec4 term, vec3 light) {
    float m = gfx_text_mask(term);
    vec3 base = gfx_straight(term);
    light = gfx_grade(light) * GFX_INTENSITY;
    light *= 1.0 - m * clamp(GFX_READABILITY, 0.0, 1.0) * 0.85;
    float a = max(term.a, clamp(gfx_luma(light) * GFX_OPACITY, 0.0, 1.0));
    return gfx_output(base + light, a);
}

// Combined: effect behind the text plus a light overlay on top.
vec4 gfx_compose_glow(vec2 uv, vec4 term, vec3 fx, vec3 light) {
    vec4 c = gfx_compose(uv, term, fx);
    float m = gfx_text_mask(term);
    light = gfx_grade(light) * GFX_INTENSITY * (1.0 - m * clamp(GFX_READABILITY, 0.0, 1.0) * 0.85);
    return gfx_output(c.rgb / max(c.a, 1e-3) + light, c.a);
}

// Post mode: a full-frame filter (CRT, colour grade). `col` is the processed
// straight-alpha image; intensity blends it against the untouched terminal.
vec4 gfx_post(vec4 term, vec3 col) {
    vec3 base = gfx_straight(term);
    col = mix(base, gfx_grade(col), GFX_INTENSITY);
    return gfx_output(col, max(term.a, GFX_OPACITY * GFX_INTENSITY));
}

// Offset applied to the terminal lookup by distortion shaders. With
// GFX_DISTORT_TEXT = 0 the text stays perfectly still (non-distorting variant).
vec2 gfx_text_offset(vec2 o) { return o * GFX_DISTORT_TEXT * GFX_INTENSITY; }

// Sine-free hashes. Based on "Hash without Sine" by David Hoskins (MIT).
// Deterministic across GPUs, unlike fract(sin(x) * big) hashes.

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float hash13(vec3 p3) {
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash21(float p) {
    vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

vec3 hash32(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

vec3 hash33(vec3 p3) {
    p3 = fract(p3 * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return fract((p3.xxy + p3.yxx) * p3.zyx);
}

// Value noise in 2D and 3D with quintic interpolation.

float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float a = hash12(i), b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0)), d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float vnoise3(vec3 p) {
    vec3 i = floor(p), f = fract(p);
    vec3 u = f * f * (3.0 - 2.0 * f);
    float n000 = hash13(i), n100 = hash13(i + vec3(1, 0, 0));
    float n010 = hash13(i + vec3(0, 1, 0)), n110 = hash13(i + vec3(1, 1, 0));
    float n001 = hash13(i + vec3(0, 0, 1)), n101 = hash13(i + vec3(1, 0, 1));
    float n011 = hash13(i + vec3(0, 1, 1)), n111 = hash13(i + vec3(1, 1, 1));
    return mix(mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
               mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y), u.z);
}

// ---- signal-interference ----
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float wave = sin(uv.y * 60.0 + t * 8.0) * sin(uv.y * 7.0 - t * 1.3) * P_WAVE * 2.0 * gfx_dpi() / iResolution.x;
    vec2 suv = uv + vec2(wave * GFX_DISTORT_TEXT, 0.0);
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(gfx_term(suv));
    // Noise bars rolling upward, tinted.
    float bar = smoothstep(0.7, 1.0, vnoise(vec2(uv.y * 12.0 - t * 2.0, t * 0.5)));
    float n = hash12(fragCoord * 0.5 + floor(t * 30.0));
    col = mix(col, vec3(n) * vec3(0.7, 0.9, 1.0), bar * P_BARS * 0.5);
    // Dropout: brief dimming of random bands.
    float drop = step(0.97, hash12(vec2(floor(uv.y * 20.0), floor(t * 6.0))));
    col *= 1.0 - gfx_flash(drop * 0.5);
    fragColor = gfx_post(term, col);
}
