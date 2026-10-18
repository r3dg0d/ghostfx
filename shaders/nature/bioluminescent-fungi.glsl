// @id bioluminescent-fungi
// @name Bioluminescent Fungi
// @category nature
// @description A cluster of mushrooms on the forest floor, caps softly pulsing teal and lime as glowing spores float up into the dark.
// @tags mushrooms, fungi, glow, forest, night, nature
// @mode background
// @uses hash sdf value
// @color PRIMARY #3DFFD2
// @color SECONDARY #020706
// @color ACCENT #B6FF5C
// @param COUNT int 9 3 16 Number of mushrooms

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    float ground = -0.42 + 0.03 * vnoise(vec2(p.x * 6.0, 0.0));
    for (int i = 0; i < P_COUNT; i++) {
        float fi = float(i);
        float h = hash11(fi * 1.7);
        float x = 0.25 + (fi / float(P_COUNT) - 0.5) * 0.9 * gfx_aspect() * 0.5 + 0.05 * hash11(fi + 3.0);
        float s = 0.4 + 0.6 * hash11(fi + 9.0);
        float stemH = 0.08 + 0.12 * s;
        vec2 q = p - vec2(x, ground);
        float stem = sd_box(q - vec2(0.004 * sin(q.y * 20.0), stemH * 0.5), vec2(0.006 + 0.005 * s, stemH * 0.5));
        vec2 cq = (q - vec2(0.0, stemH)) / vec2(0.05 + 0.04 * s, 0.03 + 0.02 * s);
        float cap = max(length(cq) - 1.0, -cq.y - 0.15);
        float pulse = 0.6 + 0.4 * sin(t * (0.8 + h) + fi * 2.0);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, h);
        col = mix(col, vec3(0.05, 0.08, 0.07), smoothstep(0.003, 0.0, stem));
        col = mix(col, c * (0.35 + 0.65 * pulse) * (0.7 + 0.3 * smoothstep(0.0, 1.0, cq.y)), smoothstep(0.08, 0.0, cap));
        col += c * 0.15 * pulse * exp(-length(q - vec2(0.0, stemH)) * 18.0);
    }
    col = mix(col, vec3(0.01, 0.02, 0.015), smoothstep(0.003, 0.0, p.y - ground) * 0.9);
    // Spores.
    vec2 g = p * 40.0 + vec2(sin(t * 0.3 + p.y * 3.0), -t * 0.6);
    vec2 id = floor(g);
    float sp = step(0.94, hash12(id)) * smoothstep(0.25, 0.0, length(fract(g) - 0.5)) * smoothstep(-0.5, 0.1, p.y);
    col += mix(GFX_PRIMARY, GFX_ACCENT, hash12(id + 1.0)) * sp * 0.7;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
