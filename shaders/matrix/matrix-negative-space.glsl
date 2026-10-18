// @id matrix-negative-space
// @name Matrix Negative Space
// @category matrix
// @description Digital rain that only falls through empty space: streams part around your text and fade out above and below each line.
// @tags matrix, rain, code, green, readable, reactive
// @mode background
// @uses hash
// @color PRIMARY #39FF6A
// @color SECONDARY #000A03
// @color ACCENT #D9FFE3
// @param CLEARANCE float 2.0 0.5 5.0 How far (in glyph-heights) rain keeps from text

float glyph5x7(vec2 f, float seed) {
    vec2 g = floor(f * vec2(5.0, 7.0));
    if (g.x < 0.0 || g.x > 4.0 || g.y < 0.0 || g.y > 6.0) return 0.0;
    return step(0.5, hash12(g + seed * 13.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);
    float cw = 1.0 / (80.0 * gfx_aspect() / 1.7778);
    float ch = cw * gfx_aspect() * 1.6;
    float cx = floor(uv.x / cw);
    float hc = hash11(cx * 1.73);
    float rows = 1.0 / ch;
    float head = fract(t * (0.2 + 0.4 * hc) * 0.25 + hc * 7.0) * rows * 1.6;
    float row = floor((1.0 - uv.y) / ch);
    float dist = head - row;
    float trail = rows * 0.55;
    float on = step(0.0, dist) * step(dist, trail);
    float fade = pow(1.0 - clamp(dist / trail, 0.0, 1.0), 1.5);
    vec2 f = (vec2(fract(uv.x / cw), fract((1.0 - uv.y) / ch)) - vec2(0.12, 0.1)) / vec2(0.76, 0.8);
    float g = glyph5x7(f, floor(hash12(vec2(cx, row)) * 50.0 + t * 2.0));
    // Keep clear of text: probe the terminal above and below this pixel.
    float px = 1.0 / iResolution.y;
    float near = 0.0;
    for (int k = -3; k <= 3; k++) {
        vec2 o = vec2(0.0, float(k) * P_CLEARANCE * 6.0 * px * gfx_dpi());
        near = max(near, gfx_text_mask(gfx_term(uv + o)));
        near = max(near, gfx_text_mask(gfx_term(uv + o + vec2(4.0 * px, 0.0))));
    }
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_PRIMARY * 0.6, GFX_PRIMARY, fade) * g * on * fade * (1.0 - near);
    col += GFX_ACCENT * g * on * smoothstep(1.5, 0.0, dist) * (1.0 - near);
    fragColor = gfx_compose(uv, term, col);
}
