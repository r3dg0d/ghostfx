// @id green-phosphor
// @name Green Phosphor
// @category crt
// @description Everything rendered as glowing P1 green phosphor on black, with scanlines and a warm halo around each glyph.
// @tags crt, green, monochrome, retro, phosphor
// @mode post
// @uses crt
// @color PRIMARY #33FF66
// @color SECONDARY #021006
// @color ACCENT #CCFFD9
// @param GLOW float 0.6 0.0 1.5 Phosphor halo strength

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);
    // Brightness relative to the terminal background drives the phosphor.
    float bgl = gfx_luma(GFX_TERM_BG);
    float l = abs(gfx_luma(gfx_straight(term)) - bgl) / max(1.0 - bgl, 0.2);
    float halo = abs(gfx_luma(term_bloom(uv, 4.0)) - bgl) / max(1.0 - bgl, 0.2);
    float e = clamp(l, 0.0, 1.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * e + GFX_ACCENT * pow(e, 4.0) * 0.4;
    col += GFX_PRIMARY * halo * P_GLOW * 0.5;
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.35);
    col *= 0.985 + 0.015 * sin(t * 50.0);
    col *= vignette(uv, 0.4);
    fragColor = gfx_post(term, col);
}
