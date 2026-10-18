// @id enchantment-table
// @name Enchantment Table
// @category minecraft
// @description Arcane glyphs peel off the air and drift in curving paths toward a glowing book at the bottom of the screen.
// @tags magic, glyphs, runes, purple, minecraft-inspired
// @mode background
// @uses hash
// @inspired Minecraft's enchanting table particles (original glyph generator, no game assets)
// @color PRIMARY #C9C2FF
// @color SECONDARY #0A0716
// @color ACCENT #6E4BFF
// @param GLYPHS int 36 8 80 Number of glyphs in flight

// Random 5x5 rune, mirrored left-right so it reads like a symbol.
float rune(float seed, vec2 g) {
    if (g.x < 0.0 || g.x >= 5.0 || g.y < 0.0 || g.y >= 5.0) return 0.0;
    float x = floor(g.x), y = floor(g.y);
    float mx = min(x, 4.0 - x);
    return step(0.5, hash12(vec2(mx + seed * 13.0, y + seed * 7.0)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 book = vec2(0.0, -0.38);

    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.25 * exp(-length(p - book) * 4.0);
    col += GFX_PRIMARY * 0.5 * smoothstep(0.03, 0.0, max(abs(p.x - book.x) - 0.06, abs(p.y - book.y) - 0.012));

    float px = 0.0045;
    for (int i = 0; i < P_GLYPHS; i++) {
        float fi = float(i);
        float dur = 3.0 + 2.0 * hash11(fi);
        float lt = t + fi * 0.37;
        float cyc = floor(lt / dur);
        float k = fract(lt / dur);
        vec2 start = (hash22(vec2(fi, cyc)) - 0.5) * vec2(gfx_aspect(), 1.0) * 0.9 + vec2(0.0, 0.15);
        // Curving path: quadratic Bezier with a sideways control point.
        vec2 ctrl = mix(start, book, 0.5) + vec2((hash11(fi + cyc) - 0.5) * 0.6, 0.25);
        float e = k * k * (3.0 - 2.0 * k);
        vec2 pos = mix(mix(start, ctrl, e), mix(ctrl, book, e), e);
        vec2 g = (p - pos) / px + 2.5;
        float b = rune(floor(hash11(fi * 3.3 + cyc) * 40.0), g);
        float fade = smoothstep(0.0, 0.15, k) * smoothstep(1.0, 0.8, k);
        col += mix(GFX_PRIMARY, GFX_ACCENT, k) * b * fade * 0.9;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
