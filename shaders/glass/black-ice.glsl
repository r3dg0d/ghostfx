// @id black-ice
// @name Black Ice
// @category glass
// @description Dark, glassy ice with trapped bubbles and hairline fractures, a slow sheen of reflected light sliding over its surface.
// @tags ice, black, dark, glossy, bubbles, subtle
// @mode background
// @uses fbm hash
// @color PRIMARY #9EC9FF
// @color SECONDARY #03060A
// @color ACCENT #2B4A6E

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.15 * fbm(p * 2.0);
    // Hairline fractures: thin ridges of noise.
    float fr = pow(ridged(p * 3.0 + 4.0), 18.0);
    col += GFX_PRIMARY * fr * 0.4;
    // Trapped bubbles at two depths.
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        vec2 g = p * (25.0 + fi * 20.0) + fi * 7.0;
        vec2 id = floor(g);
        vec2 f = fract(g) - 0.5 - (hash22(id) - 0.5) * 0.5;
        float r = 0.06 + 0.1 * hash12(id + 2.0);
        float b = step(0.85, hash12(id)) * smoothstep(0.02, 0.0, abs(length(f) - r));
        col += GFX_PRIMARY * b * (0.25 - fi * 0.08);
    }
    // Sheen.
    float s = exp(-pow((p.x * 0.6 + p.y) - (fract(t * 0.03) * 3.0 - 1.5), 2.0) * 10.0);
    col += GFX_PRIMARY * s * 0.08;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
