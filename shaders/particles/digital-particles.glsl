// @id digital-particles
// @name Digital Particles
// @category particles
// @description Tiny pixel-font ones and zeros rise like bubbles through a dark field, flickering between states.
// @tags digital, binary, particles, cyan, tech
// @mode background
// @uses hash
// @color PRIMARY #33F5FF
// @color SECONDARY #020A10
// @color ACCENT #2E6BFF

// 3x5 bitmap glyphs packed into 15 bits.
float glyph_bit(float which, vec2 g) {
    int bits = which < 0.5 ? 31599 : 9362; // '0' and '1'
    int x = int(g.x), y = int(g.y);
    if (x < 0 || x > 2 || y < 0 || y > 4) return 0.0;
    int idx = (4 - y) * 3 + (2 - x);
    return float((bits >> idx) & 1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.05 * (0.5 - p.y);

    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float sc = 14.0 + fi * 8.0;
        vec2 q = p * sc + vec2(0.0, -t * (0.8 + 0.4 * fi)) + fi * 21.0;
        vec2 id = floor(q);
        float h = hash12(id);
        if (h > 0.22) continue;
        vec2 f = fract(q);
        vec2 off = hash22(id + 1.0) * 0.4;
        vec2 g = (f - off) * 7.0;               // glyph cell grid 3x5 inside
        float which = step(0.5, hash12(id + floor(t * (0.5 + h * 3.0))));
        float b = glyph_bit(which, floor(g));
        float bright = (0.5 + 0.5 * sin(t * 3.0 + h * 80.0)) * (1.0 - fi * 0.25);
        col += mix(GFX_PRIMARY, GFX_ACCENT, fi / 2.0) * b * bright;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
