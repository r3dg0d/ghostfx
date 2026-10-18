// @id holographic-glass
// @name Holographic Glass
// @category glass
// @description Translucent sci-fi panels float at different depths, edged in light and washed with a shifting iridescent sheen.
// @tags hologram, glass, panels, futuristic, iridescent
// @mode background
// @uses sdf color hash
// @color PRIMARY #7FE9FF
// @color SECONDARY #05070D
// @color ACCENT #C49BFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float depth = 0.5 + 0.5 * hash11(fi);
        vec2 c = (hash22(vec2(fi, 1.0)) - 0.5) * vec2(gfx_aspect() * 0.9, 0.7);
        c += vec2(sin(t * 0.1 * depth + fi), cos(t * 0.08 * depth + fi)) * 0.04;
        vec2 sz = vec2(0.18 + 0.15 * hash11(fi + 3.0), 0.1 + 0.1 * hash11(fi + 5.0));
        float d = sd_box(p - c, sz) - 0.01;
        float panel = smoothstep(0.002, -0.002, d);
        float edge = exp(-abs(d) * 400.0);
        vec3 sheen = iridescence((p.x + p.y) * 1.5 + t * 0.05 + fi);
        col += mix(GFX_PRIMARY, sheen, 0.3) * panel * 0.06 * depth;
        col += mix(GFX_PRIMARY, GFX_ACCENT, hash11(fi)) * edge * 0.5 * depth;
        // Faint grid printed on each panel.
        vec2 g = abs(fract((p - c) * 40.0) - 0.5);
        col += GFX_PRIMARY * panel * smoothstep(0.45, 0.5, max(g.x, g.y)) * 0.05;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
