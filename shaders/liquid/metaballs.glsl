// @id metaballs
// @name Metaballs
// @category liquid
// @description Neon-outlined organic blobs merge and split, colours blending by each blob's influence, with ghost contour rings around them.
// @tags metaballs, blobs, neon, organic, colorful
// @mode background
// @uses hash color
// @color PRIMARY #FF3D9A
// @color SECONDARY #06050C
// @color ACCENT #3DE0FF
// @param BALLS int 6 3 10 Number of balls

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float f = 0.0;
    vec3 tint = vec3(0.0);
    for (int i = 0; i < P_BALLS; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * (0.21 + 0.07 * fi) + fi * 2.3) * 0.65, cos(t * (0.17 + 0.05 * fi) + fi * 1.1) * 0.35);
        float w = 0.012 / max(dot(p - c, p - c), 1e-4);
        f += w;
        tint += mix(GFX_PRIMARY, GFX_ACCENT, fract(fi * 0.37)) * w;
    }
    tint /= max(f, 1e-4);
    float iso = 1.0;
    float inside = smoothstep(iso * 0.98, iso * 1.02, f);
    float edge = exp(-abs(f - iso) * 18.0);
    float rings = smoothstep(0.08, 0.0, abs(fract(f * 4.0) - 0.5) - 0.42) * (1.0 - inside) * smoothstep(0.1, 0.5, f);
    vec3 col = GFX_SECONDARY;
    col += tint * inside * 0.35;
    col += tint * edge * 0.9;
    col += tint * rings * 0.12;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
