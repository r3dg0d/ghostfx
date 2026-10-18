// @module crt
// CRT building blocks: scanlines, phosphor masks, vignette, bloom taps.

float scanline(float y, float density, float strength) {
    float s = 0.5 + 0.5 * cos(y * 6.28318 * density);
    return mix(1.0, s, strength);
}

// Aperture-grille style RGB stripe mask in pixel space.
vec3 phosphor_mask(vec2 fc, float strength) {
    float x = mod(floor(fc.x / max(gfx_dpi() * 1.5, 1.0)), 3.0);
    vec3 m = vec3(x == 0.0 ? 1.0 : 0.35, x == 1.0 ? 1.0 : 0.35, x == 2.0 ? 1.0 : 0.35);
    return mix(vec3(1.0), m * 1.4, strength);
}

// Shadow-mask (triad dots) variant.
vec3 shadow_mask(vec2 fc, float strength) {
    float s = max(gfx_dpi() * 1.5, 1.0);
    vec2 c = floor(fc / s);
    float x = mod(c.x + mod(c.y, 2.0) * 1.5, 3.0);
    vec3 m = vec3(step(x, 0.99), step(0.99, x) * step(x, 1.99), step(1.99, x));
    return mix(vec3(1.0), 0.35 + m * 1.1, strength);
}

float vignette(vec2 uv, float strength) {
    vec2 c = uv * (1.0 - uv.yx);
    return mix(1.0, pow(clamp(c.x * c.y * 16.0, 0.0, 1.0), 0.3), strength);
}

// 8-tap glow of the terminal content (cheap bloom approximation).
vec3 term_bloom(vec2 uv, float radius) {
    vec2 o = radius * gfx_dpi() / iResolution.xy;
    vec3 s = vec3(0.0);
    s += gfx_term(uv + vec2(o.x, 0.0)).rgb;
    s += gfx_term(uv - vec2(o.x, 0.0)).rgb;
    s += gfx_term(uv + vec2(0.0, o.y)).rgb;
    s += gfx_term(uv - vec2(0.0, o.y)).rgb;
    s += gfx_term(uv + o * 0.7).rgb;
    s += gfx_term(uv - o * 0.7).rgb;
    s += gfx_term(uv + vec2(o.x, -o.y) * 0.7).rgb;
    s += gfx_term(uv + vec2(-o.x, o.y) * 0.7).rgb;
    return s / 8.0;
}

// Chromatic aberration lookup of the terminal.
vec3 term_chroma(vec2 uv, vec2 dir) {
    return vec3(gfx_term(uv + dir).r, gfx_term(uv).g, gfx_term(uv - dir).b);
}
