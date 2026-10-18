// GhostFX — Mandelbrot (mandelbrot) v1.0.0
// The whole Mandelbrot set, smoothly shaded, with colour bands flowing outward from its boundary.
// Category: geometric | Mode: background | Preset: balanced
// Source: shaders/geometric/mandelbrot.glsl | Built by ghostfx 0.9.0
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
#define P_X 0.35
#define GFX_PRIMARY vec3(0.4902, 0.3608, 1.0000)
#define GFX_SECONDARY vec3(0.0157, 0.0118, 0.0392)
#define GFX_ACCENT vec3(1.0000, 0.7569, 0.3020)
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

// Colour utilities: cosine palettes, HSV, tonemapping, blackbody.

// Cosine gradient palette: a + b * cos(2pi * (c * t + d)).
vec3 cospal(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}

// Narkowicz's fitted ACES filmic curve.
vec3 tonemap_aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 tonemap_reinhard(vec3 x) { return x / (1.0 + x); }

vec3 gamma_encode(vec3 c) { return pow(max(c, 0.0), vec3(1.0 / 2.2)); }
vec3 gamma_decode(vec3 c) { return pow(max(c, 0.0), vec3(2.2)); }

// Approximate blackbody colour for t in [0, 1] (cold ember -> white hot).
vec3 blackbody(float t) {
    t = clamp(t, 0.0, 1.0);
    return vec3(1.0, 0.35, 0.05) * smoothstep(0.0, 0.45, t) +
           vec3(0.0, 0.55, 0.30) * smoothstep(0.35, 0.8, t) +
           vec3(0.0, 0.10, 0.65) * smoothstep(0.7, 1.0, t);
}

// Three-stop ramp through the preset colours.
vec3 ramp3(float t, vec3 a, vec3 b, vec3 c) {
    t = clamp(t, 0.0, 1.0);
    return t < 0.5 ? mix(a, b, t * 2.0) : mix(b, c, t * 2.0 - 2.0 * 0.5);
}

// Thin-film style iridescence.
vec3 iridescence(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

// ---- mandelbrot ----
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = (p - vec2(P_X, 0.0)) * 2.6 + vec2(-0.6, 0.0);
    vec2 z = vec2(0.0);
    float n = 0.0;
    float trap = 1e3;
    for (int i = 0; i < GFX_STEPS * 2; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, abs(z.x * z.y));
        if (dot(z, z) > 256.0) break;
        n += 1.0;
    }
    vec3 col;
    if (n >= float(GFX_STEPS * 2)) {
        col = GFX_SECONDARY + GFX_PRIMARY * 0.15 * exp(-trap * 20.0);
    } else {
        float sn = n - log2(log2(dot(z, z))) + 4.0;
        float k = sqrt(sn) * 0.3 - t * 0.08;
        col = mix(GFX_PRIMARY, GFX_ACCENT, 0.5 + 0.5 * sin(k * 6.2831)) * smoothstep(0.0, 6.0, sn) * 0.9;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
