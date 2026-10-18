// @id crt-interlaced
// @name CRT Interlaced
// @category crt
// @description Alternating odd and even fields with a soft half-line offset, the shimmer of an interlaced broadcast monitor.
// @tags crt, interlaced, broadcast, retro
// @mode post
// @uses crt
// @flashing true
// @param FIELD_PX float 2.0 1.0 6.0 Field line height in pixels (at 1440p)
// @param DEPTH float 0.35 0.0 0.8 Darkening of the inactive field

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    // Field parity flips at 30 Hz (or slower with reduced motion / flash).
    float rate = GFX_REDUCED_FLASH > 0.5 ? 4.0 : 30.0;
    float field = mod(floor(t * rate), 2.0);
    float line = floor(fragCoord.y / (P_FIELD_PX * gfx_dpi()));
    float live = step(0.5, abs(mod(line, 2.0) - field));
    vec4 term = gfx_term(uv);
    // The inactive field shows the image shifted by half a line.
    vec3 other = gfx_straight(gfx_term(uv + vec2(0.0, P_FIELD_PX * gfx_dpi() * 0.5 / iResolution.y)));
    vec3 col = mix(other * (1.0 - P_DEPTH), gfx_straight(term), live);
    col *= 1.0 + P_DEPTH * 0.5;
    col *= vignette(uv, 0.3);
    fragColor = gfx_post(term, col);
}
