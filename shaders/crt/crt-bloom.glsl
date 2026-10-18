// @id crt-bloom
// @name CRT Bloom
// @category crt
// @description Soft, generous phosphor glow: bright text spills light into the surrounding glass, over faint scanlines.
// @tags crt, bloom, glow, retro, soft
// @mode post
// @uses crt
// @animated false
// @param RADIUS float 6.0 2.0 14.0 Glow radius in pixels (at 1440p)
// @param AMOUNT float 0.8 0.0 2.0 Glow amount

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec4 term = gfx_term(uv);
    vec3 base = gfx_straight(term);
    vec3 bg = GFX_TERM_BG;
    // Two rings of taps approximate a wide Gaussian.
    vec3 g1 = max(term_bloom(uv, P_RADIUS * 0.5) - bg, 0.0);
    vec3 g2 = max(term_bloom(uv, P_RADIUS) - bg, 0.0);
#if GFX_QUALITY >= 2
    vec3 g3 = max(term_bloom(uv, P_RADIUS * 2.0) - bg, 0.0);
#else
    vec3 g3 = g2;
#endif
    vec3 col = base + (g1 * 0.5 + g2 * 0.35 + g3 * 0.25) * P_AMOUNT;
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.2);
    col *= vignette(uv, 0.25);
    fragColor = gfx_post(term, col);
}
