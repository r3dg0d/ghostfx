// @id cosmic-dust
// @name Cosmic Dust
// @category space
// @description Soft veils of interstellar dust drift across a sparse starfield on several parallax layers. Very calm.
// @tags space, dust, calm, subtle, clouds
// @mode background
// @uses fbm hash
// @color PRIMARY #8C7BFF
// @color SECONDARY #05040C
// @color ACCENT #FFB38A

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    vec2 g = p * 70.0;
    col += vec3(0.8) * step(0.988, hash12(floor(g))) * smoothstep(0.3, 0.0, length(fract(g) - 0.5));
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = p * (1.2 + fi * 0.8) + vec2(t * (0.015 + 0.01 * fi), fi * 4.0);
        float d = fbm(q + 0.5 * fbm(q * 2.0));
        float veil = smoothstep(0.35, 0.85, d);
        col = mix(col, mix(GFX_PRIMARY, GFX_ACCENT, fi / 2.0) * (0.25 + 0.15 * fi), veil * (0.5 - fi * 0.1));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
