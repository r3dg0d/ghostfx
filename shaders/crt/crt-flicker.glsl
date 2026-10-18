// @id crt-flicker
// @name CRT Flicker
// @category crt
// @description An ageing tube: a subtle unsteady brightness and a soft refresh band that rolls slowly down the screen.
// @tags crt, flicker, retro, subtle
// @mode post
// @uses crt value
// @flashing true
// @param FLICKER float 0.04 0.0 0.15 Brightness instability (fraction)
// @param BAND float 0.08 0.0 0.3 Rolling band strength
// @preset subtle FLICKER=0.02 BAND=0.04

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(term);
    // Slow noise flicker plus a gentle mains-hum beat; never a hard strobe.
    float fl = (vnoise(vec2(t * 6.0, 0.0)) - 0.5) * 2.0 * P_FLICKER + 0.01 * sin(t * 6.2831 * 0.7);
    col *= 1.0 + gfx_flash(fl);
    float band = exp(-pow((fract(uv.y + t * 0.07) - 0.5) * 6.0, 2.0));
    col *= 1.0 + gfx_flash(band * P_BAND);
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.25);
    col *= vignette(uv, 0.3);
    fragColor = gfx_post(term, col);
}
