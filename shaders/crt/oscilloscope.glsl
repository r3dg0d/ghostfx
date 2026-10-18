// @id oscilloscope
// @name Oscilloscope
// @category crt
// @description An old monochrome oscilloscope tracing slowly morphing Lissajous figures in glowing green over its graticule.
// @tags oscilloscope, lissajous, green, retro, science, phosphor
// @mode background
// @uses sdf
// @color PRIMARY #6BFF8F
// @color SECONDARY #020703
// @color ACCENT #D8FFE0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = (p - vec2(0.45, 0.0)) / 0.32;
    vec3 col = GFX_SECONDARY;
    float screen = step(max(abs(c.x), abs(c.y)), 1.0);
    col += GFX_PRIMARY * grid_lines(c * 5.0, 1.0) * 0.12 * screen;
    // Lissajous curve x = sin(a s + phase), y = sin(b s), sampled as a polyline.
    float a = 3.0, b = 2.0 + 0.5 * sin(t * 0.05);
    float phase = t * 0.3;
    float d = 1e3;
    vec2 prev = vec2(sin(phase), 0.0) * 0.85;
    for (int i = 1; i <= 96; i++) {
        float s = float(i) / 96.0 * 6.2831;
        vec2 cur = vec2(sin(a * s + phase), sin(b * s)) * 0.85;
        d = min(d, sd_segment(c, prev, cur));
        prev = cur;
    }
    col += GFX_PRIMARY * (smoothstep(0.02, 0.0, d) * 0.9 + exp(-d * 18.0) * 0.25) * screen;
    col += GFX_ACCENT * smoothstep(0.008, 0.0, d) * 0.4 * screen;
    col += GFX_PRIMARY * smoothstep(0.02, 0.0, abs(max(abs(c.x), abs(c.y)) - 1.0)) * 0.2;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
