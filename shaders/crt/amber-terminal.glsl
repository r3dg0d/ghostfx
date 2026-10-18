// @id amber-terminal
// @name Amber Terminal
// @category crt
// @description A warm amber monochrome monitor whose slow phosphor leaves a faint smear trailing below the text.
// @tags crt, amber, monochrome, retro, warm
// @mode post
// @uses crt
// @color PRIMARY #FFB000
// @color SECONDARY #140A00
// @color ACCENT #FFE7B0
// @param SMEAR float 0.5 0.0 1.0 Afterglow smear strength (approximation, no frame feedback)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec4 term = gfx_term(uv);
    float bgl = gfx_luma(GFX_TERM_BG);
    float norm = 1.0 / max(1.0 - bgl, 0.2);
    float l = clamp((gfx_luma(gfx_straight(term)) - bgl) * norm, 0.0, 1.0);
    // Ghostty gives no previous frame, so afterglow is approximated by a
    // decaying smear of the current frame below each glyph.
    float smear = 0.0;
    vec2 px = vec2(0.0, 1.0 / iResolution.y) * gfx_dpi();
    for (int i = 1; i <= 6; i++) {
        float fi = float(i);
        float s = clamp((gfx_luma(gfx_straight(gfx_term(uv + px * fi * 2.0))) - bgl) * norm, 0.0, 1.0);
        smear = max(smear, s * exp(-fi * 0.5));
    }
    float e = max(l, smear * P_SMEAR * 0.6);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * e + GFX_ACCENT * pow(l, 5.0) * 0.35;
    col += GFX_PRIMARY * clamp((gfx_luma(term_bloom(uv, 4.0)) - bgl) * norm, 0.0, 1.0) * 0.3;
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.3);
    col *= vignette(uv, 0.45);
    fragColor = gfx_post(term, col);
}
