// @id alien-language
// @name Alien Language
// @category alien
// @description Columns of curving, unreadable glyphs assemble stroke by stroke, glow, then dissolve into new symbols.
// @tags alien, glyphs, language, symbols, mysterious
// @mode background
// @uses hash sdf
// @color PRIMARY #FF9E3D
// @color SECONDARY #0A0604
// @color ACCENT #FFE1A8
// @param SIZE float 26.0 12.0 60.0 Glyph rows per screen height

// A glyph is up to four strokes chosen from arcs and bars on a 3x3 lattice.
float alien_glyph(vec2 f, float seed, float grow) {
    float d = 1e3;
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float h = hash11(seed * 13.7 + fi * 3.1);
        if (fi / 4.0 > grow) break;
        vec2 a = floor(hash22(vec2(seed, fi)) * 3.0) / 2.0 - 0.5;
        vec2 b = floor(hash22(vec2(seed, fi + 9.0)) * 3.0) / 2.0 - 0.5;
        if (h < 0.5) d = min(d, sd_segment(f, a * 0.7, b * 0.7));
        else d = min(d, abs(length(f - a * 0.5) - 0.3 + 0.1 * h));
    }
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_SIZE;
    g.y += t * 0.4 * (0.5 + hash11(floor(g.x / 1.6)));
    vec2 id = floor(vec2(g.x / 1.6, g.y));
    vec2 f = vec2(fract(g.x / 1.6) * 1.6 - 0.8, fract(g.y) - 0.5) * 1.3;
    float life = fract(t * 0.15 + hash12(id));
    float seed = floor(t * 0.15 + hash12(id)) + hash12(id) * 100.0;
    float present = step(0.62, hash12(id + 5.0));
    float grow = smoothstep(0.0, 0.4, life);
    float fade = smoothstep(1.0, 0.75, life);
    float d = alien_glyph(f, seed, grow);
    float stroke = smoothstep(0.08, 0.03, d) * present * fade;
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.6, 0.0, life)) * stroke * 0.8;
    col += GFX_PRIMARY * glow(d, 0.05) * present * fade * 0.12;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
