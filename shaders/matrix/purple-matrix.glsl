// @id purple-matrix
// @name Purple Matrix
// @category matrix
// @description A violet take on digital rain using katakana-like strokes, with depth: near columns large and bright, far ones small and dim.
// @tags matrix, purple, code, rain, depth
// @mode background
// @uses hash
// @color PRIMARY #B44DFF
// @color SECONDARY #07020D
// @color ACCENT #F3D9FF

// Stroke-based glyph: a few random horizontal, vertical and diagonal strokes.
float stroke_glyph(vec2 f, float seed) {
    if (f.x < 0.0 || f.x > 1.0 || f.y < 0.0 || f.y > 1.0) return 0.0;
    float d = 1.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float h = hash11(seed + fi * 3.7);
        float k = hash11(seed * 1.3 + fi);
        if (h < 0.33) d = min(d, abs(f.y - k));
        else if (h < 0.66) d = min(d, abs(f.x - k) + step(f.y, 0.3 * k));
        else d = min(d, abs(f.x - f.y * (k * 2.0 - 1.0) - 0.5 * (1.0 - k)));
    }
    return smoothstep(0.12, 0.05, d);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int L = 0; L < 3; L++) {
        float fl = float(L);
        float scale = 1.0 - fl * 0.3;          // layer 0 = near
        float cols = (40.0 + fl * 35.0) * gfx_aspect() / 1.7778;
        float cw = 1.0 / cols;
        float ch = cw * gfx_aspect() * 1.4;
        float cx = floor(uv.x / cw + fl * 0.37);
        float hc = hash11(cx * 1.37 + fl * 11.0);
        if (hc > 0.6) continue;
        float rows = 1.0 / ch;
        float head = fract(t * (0.12 + 0.2 * hc) * scale + hc * 5.0) * rows * 1.6;
        float row = floor((1.0 - uv.y) / ch);
        float dist = head - row;
        float trail = rows * 0.5;
        float on = step(0.0, dist) * step(dist, trail);
        float fade = pow(1.0 - clamp(dist / trail, 0.0, 1.0), 2.0);
        vec2 f = vec2(fract(uv.x / cw + fl * 0.37), fract((1.0 - uv.y) / ch));
        f = (f - 0.15) / 0.7;
        float seed = floor(hash12(vec2(cx, row)) * 30.0 + t * 2.0 * hash12(vec2(row, cx + fl)));
        float g = stroke_glyph(f, seed + fl * 100.0);
        col += mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(2.0, 0.0, dist)) * g * on * fade * (1.0 - fl * 0.3);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
