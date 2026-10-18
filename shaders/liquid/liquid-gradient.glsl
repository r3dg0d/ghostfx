// @id liquid-gradient
// @name Liquid Gradient
// @category liquid
// @description A soft mesh gradient of four drifting colour pools, gently warped, like a modern app background in slow motion.
// @tags gradient, mesh, calm, modern, soft, minimal
// @mode background
// @uses gradient
// @color PRIMARY #6E56FF
// @color SECONDARY #0E0B1F
// @color ACCENT #FF6EC4

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time() * 0.15;
    vec2 q = p + 0.15 * vec2(gnoise(p * 1.2 + t), gnoise(p * 1.2 - t + 4.0));
    vec3 cols[4];
    cols[0] = GFX_PRIMARY;
    cols[1] = GFX_ACCENT;
    cols[2] = mix(GFX_PRIMARY, vec3(0.2, 0.8, 1.0), 0.6);
    cols[3] = GFX_SECONDARY * 2.0;
    vec3 acc = vec3(0.0);
    float wsum = 0.0;
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * (0.7 + 0.2 * fi) + fi * 1.9) * 0.6 * gfx_aspect() * 0.5, cos(t * (0.6 + 0.15 * fi) + fi * 2.6) * 0.35);
        float w = exp(-dot(q - c, q - c) * 4.0);
        acc += cols[i] * w;
        wsum += w;
    }
    vec3 col = mix(GFX_SECONDARY, acc / max(wsum, 1e-3), clamp(wsum * 1.5, 0.0, 1.0));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
