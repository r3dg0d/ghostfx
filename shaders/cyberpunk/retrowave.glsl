// @id retrowave
// @name Retrowave
// @category cyberpunk
// @description Stacked neon waveforms ripple across the screen like an 80s oscilloscope album cover, hot pink fading into cyan.
// @tags retrowave, waves, neon, 80s, lines
// @mode background
// @uses gradient
// @color PRIMARY #FF2E88
// @color SECONDARY #0A0414
// @color ACCENT #2EE8FF
// @param LINES int 18 6 40 Number of wave lines

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    float occl = 0.0;
    // Front-to-back so nearer lines hide the ones behind them.
    for (int i = 0; i < P_LINES; i++) {
        float fi = float(i);
        float k = fi / float(P_LINES);
        float y0 = -0.42 + k * 0.84;
        float amp = 0.07 * exp(-p.x * p.x * 3.0) * (0.6 + 0.4 * sin(t * 0.5 + fi));
        float wave = y0 + amp * (sin(p.x * 9.0 - t * 1.5 + fi * 0.7) + 0.6 * gnoise(vec2(p.x * 6.0 + t * 0.4, fi)));
        float d = p.y - wave;
        float line = smoothstep(0.004, 0.0, abs(d));
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, k);
        col = mix(col, GFX_SECONDARY, step(d, 0.0) * step(-0.08, d) * (1.0 - occl) * 0.0);
        col += c * (line + exp(-abs(d) * 90.0) * 0.15);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
