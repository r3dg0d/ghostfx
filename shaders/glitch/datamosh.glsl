// @id datamosh
// @name Datamosh
// @category glitch
// @description Video-codec meltdown: macroblocks smear along stale motion vectors and colour bleeds between neighbouring blocks.
// @tags glitch, datamosh, codec, blocks, melt
// @mode post
// @uses hash value
// @distorts true
// @param BLOCK float 16.0 8.0 48.0 Macroblock size in pixels (at 1440p)
// @param AMOUNT float 0.35 0.0 1.0 Fraction of blocks that mosh
// @preset subtle AMOUNT=0.12

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float bs = P_BLOCK * gfx_dpi();
    vec2 blk = floor(fragCoord / bs);
    float era = floor(t * 0.8);
    float h = hash12(blk + era * 7.0);
    float mosh = step(1.0 - P_AMOUNT, h) * GFX_DISTORT_TEXT;
    // Stale motion vector, constant per block per era, growing within the era.
    vec2 mv = (hash22(blk + era) - 0.5) * vec2(3.0, 1.5) * bs * fract(t * 0.8);
    vec2 within = fract(fragCoord / bs);
    vec2 src = (blk * bs + within * bs * mix(1.0, 0.3, mosh) - mv * mosh) / iResolution.xy;
    vec4 term = gfx_term(mix(uv, src, mosh));
    vec3 col = gfx_straight(term);
    // Chroma bleeds from the neighbouring block.
    vec3 nb = gfx_straight(gfx_term((blk + vec2(1.0, 0.0) + 0.5) * bs / iResolution.xy));
    float l = gfx_luma(col);
    col = mix(col, l + (nb - gfx_luma(nb)), mosh * 0.6);
    fragColor = gfx_post(term, col);
}
