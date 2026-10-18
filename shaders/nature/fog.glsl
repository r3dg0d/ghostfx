// @id fog
// @name Fog
// @category nature
// @description Layers of soft grey fog drift slowly sideways at different speeds. Quiet and very easy on the eyes.
// @tags fog, mist, calm, minimal, grey
// @mode background
// @uses fbm
// @color PRIMARY #8D97A5
// @color SECONDARY #0E1014
// @color ACCENT #5D6878

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = p * vec2(1.2 + fi * 0.5, 2.5 + fi) + vec2(t * (0.03 + 0.02 * fi), fi * 5.0);
        float f = fbm(q + 0.3 * fbm(q * 2.0 + t * 0.02));
        float layer = smoothstep(0.35, 0.8, f) * (0.35 + 0.15 * fi);
        col = mix(col, mix(GFX_ACCENT, GFX_PRIMARY, fi / 2.0), layer * smoothstep(0.6, -0.4, p.y + fi * 0.1));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
