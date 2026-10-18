// @id matrix-rain
// @name Matrix Rain
// @category matrix
// @description Columns of glowing green glyphs cascade down the screen behind the text, each column with its own speed and bright leading character.
// @tags matrix, code, rain, green, hacker, classic
// @mode background
// @uses hash
// @color PRIMARY #3BFF6B
// @color SECONDARY #000A03
// @color ACCENT #D9FFE3
// @param COLUMNS float 90.0 30.0 240.0 Glyph columns across a 16:9 screen
// @param TRAIL float 0.6 0.2 1.0 Trail length (fraction of screen)

// Procedural 5x7 glyph: random pixels, mirrored-ish, re-rolled over time.
float rain_glyph(vec2 f, float seed) {
    vec2 g = floor(f * vec2(5.0, 7.0));
    if (g.x < 0.0 || g.x > 4.0 || g.y < 0.0 || g.y > 6.0) return 0.0;
    return step(0.45, hash12(g + seed * 17.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float cols = P_COLUMNS * gfx_aspect() / 1.7778;
    float cw = 1.0 / cols;
    float ch = cw * gfx_aspect() * 1.6;      // glyph cell height in uv units
    float cx = floor(uv.x / cw);
    float hc = hash11(cx * 1.73);
    float speed = 0.25 + 0.5 * hc;
    // Head position (in rows) for this column; trails extend above it.
    float rows = 1.0 / ch;
    float head = fract(t * speed * 0.25 + hc * 7.0) * (rows * (1.0 + P_TRAIL) ) ;
    float row = floor((1.0 - uv.y) / ch);
    float dist = head - row;                                  // rows behind the head
    float trail = rows * P_TRAIL;
    float on = step(0.0, dist) * step(dist, trail);
    float fade = pow(1.0 - clamp(dist / trail, 0.0, 1.0), 1.5);
    vec2 f = vec2(fract(uv.x / cw), fract((1.0 - uv.y) / ch));
    f = (f - vec2(0.12, 0.1)) / vec2(0.76, 0.8);
    float seed = floor(hash12(vec2(cx, row)) * 50.0 + t * (1.0 + 4.0 * hash12(vec2(row, cx))));
    float gl = rain_glyph(f, seed);
    vec3 col = GFX_SECONDARY;
    vec3 c = mix(GFX_PRIMARY * 0.6, GFX_PRIMARY, fade);
    col += c * gl * on * fade;
    col += GFX_ACCENT * gl * on * smoothstep(1.5, 0.0, dist);    // bright leading glyph
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
