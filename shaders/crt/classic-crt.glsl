// @id classic-crt
// @name Classic CRT
// @category crt
// @description A flat, well-adjusted CRT: crisp scanlines, a faint aperture grille, soft glow and gently darkened corners.
// @tags crt, retro, scanlines, monitor, subtle
// @mode post
// @uses crt
// @animated false
// @param LINE_PX float 3.0 2.0 8.0 Scanline pitch in pixels (at 1440p)
// @param SCANLINES float 0.45 0.0 1.0 Scanline darkness
// @param MASK float 0.25 0.0 1.0 Aperture grille strength
// @param BLOOM float 0.35 0.0 1.0 Glow amount
// @preset subtle SCANLINES=0.25 MASK=0.1
// @preset cinematic SCANLINES=0.65 MASK=0.45 BLOOM=0.5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(term);
    col += term_bloom(uv, 3.0) * P_BLOOM * 0.6;
    col *= scanline(fragCoord.y, 1.0 / (P_LINE_PX * gfx_dpi()), P_SCANLINES);
    col *= phosphor_mask(fragCoord, P_MASK);
    col *= vignette(uv, 0.35);
    col *= 1.0 + P_SCANLINES * 0.35;
    fragColor = gfx_post(term, col);
}
