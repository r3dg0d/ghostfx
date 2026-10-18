// @id compression-artifacts
// @name Compression Artifacts
// @category glitch
// @description An over-compressed video stream: 8x8 block averaging, posterised banding and ringing around sharp edges.
// @tags glitch, jpeg, compression, blocks, lofi
// @mode post
// @uses hash
// @param QUALITY_LOSS float 0.4 0.0 1.0 How badly the image is compressed
// @preset subtle QUALITY_LOSS=0.15

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float bs = 8.0 * max(floor(gfx_dpi() * 1.5), 1.0);
    vec2 blk = floor(fragCoord / bs);
    vec2 f = fract(fragCoord / bs);
    vec2 cuv = (blk + 0.5) * bs / iResolution.xy;
    vec4 term = gfx_term(uv);
    vec3 orig = gfx_straight(term);
    // DC term: block average from 4 taps.
    vec2 q = bs * 0.25 / iResolution.xy;
    vec3 dc = (gfx_straight(gfx_term(cuv + q)) + gfx_straight(gfx_term(cuv - q))
             + gfx_straight(gfx_term(cuv + vec2(q.x, -q.y))) + gfx_straight(gfx_term(cuv + vec2(-q.x, q.y)))) * 0.25;
    float loss = P_QUALITY_LOSS * (0.7 + 0.3 * step(0.5, hash12(blk + floor(t * 2.0))));
    // Ringing: a low-order cosine basis pattern weighted by local contrast.
    float contrast = length(orig - dc);
    float ring = cos(f.x * 3.1416 * 2.0) * cos(f.y * 3.1416) * contrast;
    vec3 col = mix(orig, dc, loss * 0.6) + ring * loss * 0.25;
    float levels = mix(64.0, 6.0, loss);
    col = floor(col * levels + 0.5) / levels;
    fragColor = gfx_post(term, col);
}
