// @id corrupted-memory
// @name Corrupted Memory
// @category glitch
// @description The background becomes a live memory dump: bit-pattern blocks flip and decay, and now and then a cell inverts.
// @tags glitch, memory, bits, hex, hacker
// @mode background
// @uses hash
// @color PRIMARY #3BFFB0
// @color SECONDARY #050807
// @color ACCENT #FF3B6B
// @param CELL float 22.0 10.0 60.0 Block size in pixels (at 1440p)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float cs = P_CELL * gfx_dpi();
    vec2 blk = floor(fragCoord / cs);
    vec2 f = fract(fragCoord / cs);
    float era = floor(t * (1.0 + 3.0 * hash12(blk)));
    float h = hash12(blk + era * 3.1);

    // 4x4 bit pattern inside each block.
    vec2 bit = floor(f * 4.0);
    float b = step(0.5, hash12(bit + blk * 4.0 + era));
    float pad = step(0.12, fract(f.x * 4.0)) * step(0.12, fract(f.y * 4.0));
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * b * pad * 0.22 * step(0.35, h);
    // Corrupted blocks: red with a sweep.
    float bad = step(0.985, h);
    col = mix(col, GFX_ACCENT * (0.4 + 0.6 * b), bad * pad);
    vec4 term = gfx_term(uv);
    vec4 c = gfx_compose(uv, term, col);
    // Rare whole-cell inversion that also hits glyphs.
    float inv = step(0.997, hash12(blk + floor(t * 3.0) * 11.0)) * GFX_DISTORT_TEXT;
    c.rgb = mix(c.rgb, c.a - c.rgb, inv * gfx_flash(1.0) * 0.9);
    fragColor = c;
}
