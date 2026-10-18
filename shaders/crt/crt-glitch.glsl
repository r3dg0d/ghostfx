// @id crt-glitch
// @name CRT Glitch
// @category crt
// @description A dependable CRT that every few seconds suffers a brief burst of torn lines, colour fringing and block noise.
// @tags crt, glitch, retro, digital
// @mode post
// @uses crt hash
// @flashing true
// @distorts true
// @param RATE float 0.25 0.0 1.0 Chance of a glitch in each one-second slot
// @param STRENGTH float 1.0 0.0 2.0 Glitch displacement strength
// @preset subtle RATE=0.1 STRENGTH=0.5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float slot = floor(t);
    float lt = fract(t);
    float on = step(1.0 - P_RATE, hash11(slot * 1.31)) * step(lt, 0.25 + 0.2 * hash11(slot));
    on *= GFX_DISTORT_TEXT;

    float band = floor(uv.y * (8.0 + 20.0 * hash11(slot + 3.0)));
    float bh = hash12(vec2(band, floor(t * 15.0)));
    float shift = (bh - 0.5) * 0.06 * step(0.6, bh) * on * P_STRENGTH;
    vec2 suv = uv + vec2(shift, 0.0);
    float ca = 0.004 * on * P_STRENGTH;
    vec3 col = term_chroma(suv, vec2(ca, 0.0));
    vec4 term = gfx_term(suv);

    // Block noise inside some glitch bands.
    vec2 blk = floor(fragCoord / (12.0 * gfx_dpi()));
    float bn = step(0.97, hash12(blk + floor(t * 20.0))) * on;
    col = mix(col, vec3(hash12(blk), hash12(blk + 1.0), hash12(blk + 2.0)), bn * gfx_flash(0.8));

    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.35);
    col *= phosphor_mask(fragCoord, 0.15);
    col *= vignette(uv, 0.35) * 1.1;
    fragColor = gfx_post(term, col);
}
