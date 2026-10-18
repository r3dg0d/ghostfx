// @id crystal-cave
// @name Crystal Cave
// @category nature
// @description Deep underground, clusters of faceted crystals jut from the cave walls, glowing teal and amethyst from within.
// @tags crystal, cave, glow, purple, teal, underground
// @mode background
// @uses hash sdf fbm
// @color PRIMARY #5DF0E0
// @color SECONDARY #05040A
// @color ACCENT #B86BFF

// A crystal: elongated hexagonal prism with a pointed tip, seen side-on.
float crystal(vec2 p, float w, float h) {
    p.x = abs(p.x);
    float side = p.x - w;
    float bottom = -p.y;
    float tip = ((p.y - h) * 0.6 + p.x - w) * 0.85;      // pointed cap above height h
    return max(max(side, bottom), tip);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + vec3(0.02, 0.015, 0.03) * fbm(p * 4.0);
    for (int i = 0; i < 12; i++) {
        float fi = float(i);
        float h = hash11(fi * 1.31);
        bool top = h > 0.6;
        vec2 base = vec2((hash11(fi * 7.1) - 0.5) * gfx_aspect(), top ? 0.52 : -0.52);
        float ang = (hash11(fi * 3.3) - 0.5) * 1.2 + (top ? 3.1416 : 0.0);
        vec2 q = gfx_rot(-ang) * (p - base);
        float w = 0.015 + 0.02 * hash11(fi + 2.0);
        float hgt = 0.12 + 0.25 * hash11(fi + 5.0);
        float d = crystal(q, w, hgt);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, step(0.5, hash11(fi + 9.0)));
        float pulse = 0.7 + 0.3 * sin(t * 0.8 + fi * 1.7);
        float facet = 0.6 + 0.4 * sign(q.x) * 0.5 + 0.2 * smoothstep(0.0, hgt, q.y);
        col = mix(col, c * facet * 0.6 * pulse, smoothstep(0.003, -0.003, d));
        col += c * exp(-max(d, 0.0) * 40.0) * 0.12 * pulse;
        col += vec3(1.0) * smoothstep(0.002, 0.0, abs(d)) * 0.15;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
