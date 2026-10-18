// @id blue-phosphor
// @name Blue Phosphor
// @category crt
// @description Cold blue-white monochrome phosphor with a fine dot mask and the faintest horizontal sync jitter.
// @tags crt, blue, monochrome, retro, cold
// @mode post
// @uses crt hash
// @color PRIMARY #6FB6FF
// @color SECONDARY #020611
// @color ACCENT #E6F3FF
// @param JITTER float 0.5 0.0 2.0 Horizontal sync jitter in pixels

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float line = floor(fragCoord.y / (3.0 * gfx_dpi()));
    float j = (hash12(vec2(line, floor(t * 20.0))) - 0.5) * P_JITTER * gfx_flash(1.0) / iResolution.x;
    vec2 suv = uv + vec2(j, 0.0);
    vec4 term = gfx_term(suv);
    float bgl = gfx_luma(GFX_TERM_BG);
    float norm = 1.0 / max(1.0 - bgl, 0.2);
    float e = clamp((gfx_luma(gfx_straight(term)) - bgl) * norm, 0.0, 1.0);
    float halo = clamp((gfx_luma(term_bloom(suv, 3.0)) - bgl) * norm, 0.0, 1.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * e * 0.9 + GFX_ACCENT * pow(e, 3.0) * 0.5 + GFX_PRIMARY * halo * 0.35;
    col *= shadow_mask(fragCoord, 0.25);
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.3) * 1.15;
    col *= vignette(uv, 0.4);
    fragColor = gfx_post(term, col);
}
