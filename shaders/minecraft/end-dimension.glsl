// @id end-dimension
// @name End Dimension
// @category minecraft
// @description A pale blocky island floats in an endless dark void, ringed by distant pillars and drifting purple particles.
// @tags void, purple, island, pixel, minecraft-inspired
// @mode background
// @uses value hash sdf
// @inspired Minecraft's End dimension (original procedural interpretation, no game assets)
// @color PRIMARY #B57CFF
// @color SECONDARY #07060D
// @color ACCENT #DCD9A0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float PX = 120.0;
    vec2 q = (floor(p * PX) + 0.5) / PX;

    vec3 col = GFX_SECONDARY + vec3(0.03, 0.02, 0.05) * (1.0 - abs(q.y) * 2.0);

    // The island: a blocky heightmap with a tapering, stepped underside.
    float W = 0.62;
    float xn = q.x / W;
    float top = -0.24 + 0.03 * vnoise(vec2(floor(q.x * 24.0), 0.0)) - 0.06 * xn * xn;
    float bottom = top - 0.28 * max(1.0 - xn * xn, 0.0) - 0.02 * vnoise(vec2(floor(q.x * 30.0), 3.0));
    if (abs(xn) < 1.0 && q.y < top && q.y > bottom) {
        float tex = hash12(floor(q * PX));
        col = GFX_ACCENT * (0.42 + 0.16 * tex) * mix(0.45, 1.0, smoothstep(bottom, top, q.y));
    }
    // Obsidian pillars standing on the island, crystals glowing on top.
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float x = (fi - 2.0) * 0.24;
        float h = 0.12 + 0.2 * hash11(fi + 2.0);
        float w = 0.018 + 0.008 * hash11(fi + 7.0);
        float base = -0.24 - 0.06 * (x / W) * (x / W);
        if (abs(q.x - x) < w && q.y < base + h && q.y > base) col = vec3(0.1, 0.06, 0.16) + 0.05 * hash12(floor(q * PX));
        vec2 c = q - vec2(x, base + h + 0.018);
        col += GFX_PRIMARY * (1.8 * smoothstep(0.013, 0.0, max(abs(c.x), abs(c.y))) + 0.25 * glow(length(c), 0.025)) * (0.7 + 0.3 * sin(t * 2.0 + fi));
    }
    // Purple particles drifting up.
    vec2 g = p * 40.0 + vec2(0.0, -t * 1.5);
    vec2 id = floor(g);
    if (hash12(id) < 0.06) {
        vec2 f = fract(g) - 0.5;
        col += GFX_PRIMARY * step(max(abs(f.x), abs(f.y)), 0.12) * (0.6 + 0.4 * sin(t * 3.0 + hash12(id + 1.0) * 30.0));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
