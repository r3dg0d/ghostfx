// @id retro-dos
// @name Retro DOS
// @category crt
// @description Your terminal as a 1990 DOS session: VGA blue background, light-grey text on a visible 8x16 character grid, gentle CRT softness.
// @tags dos, retro, vga, blue, 90s, nostalgia
// @mode post
// @uses crt
// @animated false
// @color PRIMARY #0000AA
// @color SECONDARY #AAAAAA
// @color ACCENT #FFFFFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec4 term = gfx_term(uv);
    float m = gfx_text_mask(term);
    vec3 src = gfx_straight(term);
    // Glyphs take a 16-colour-ish grey/white ramp by brightness.
    float l = gfx_luma(src);
    vec3 text = mix(GFX_SECONDARY, GFX_ACCENT, step(0.75, l));
    vec3 col = mix(GFX_PRIMARY, text, m);
    // Subtle cell grid and CRT softness.
    vec2 cell = fract(fragCoord / (vec2(8.0, 16.0) * gfx_dpi() * 1.5));
    float grid = smoothstep(0.0, 0.06, cell.x) * smoothstep(0.0, 0.03, cell.y);
    col *= 0.94 + 0.06 * grid;
    col += max(term_bloom(uv, 2.0) - GFX_TERM_BG, 0.0) * 0.15;
    col *= scanline(fragCoord.y, 1.0 / (2.0 * gfx_dpi()), 0.15);
    fragColor = gfx_post(term, col);
}
