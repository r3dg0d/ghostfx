// @id crt-rgb-mask
// @name CRT RGB Mask
// @category crt
// @description A close-up of the tube: clearly resolved red, green and blue phosphor triads with scanline gaps.
// @tags crt, rgb, phosphor, mask, retro
// @mode post
// @uses crt
// @animated false
// @param MASK float 0.75 0.0 1.0 Shadow mask strength
// @param SCALE float 1.5 1.0 4.0 Triad size multiplier

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(term) + term_bloom(uv, 2.0) * 0.25;
    vec2 fc = fragCoord / P_SCALE;
    col *= shadow_mask(fc, P_MASK);
    col *= scanline(fragCoord.y, 1.0 / (3.0 * P_SCALE * gfx_dpi() * 0.7), 0.4);
    col *= 1.0 + P_MASK * 0.7;
    fragColor = gfx_post(term, col);
}
