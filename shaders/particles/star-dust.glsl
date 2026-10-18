// @id star-dust
// @name Star Dust
// @category particles
// @description Multicoloured cosmic dust drifts slowly through faint nebular haze, twinkling as it passes.
// @tags space, dust, particles, colorful, calm
// @mode background
// @uses fbm particles color
// @color PRIMARY #6E7BFF
// @color SECONDARY #04040A
// @color ACCENT #FF8FD1

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float neb = fbm(p * 1.5 + vec2(t * 0.01, 0.0));
    vec3 col = GFX_SECONDARY + mix(GFX_PRIMARY, GFX_ACCENT, fbm(p * 0.8 + 3.0)) * pow(neb, 3.0) * 0.25;

    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float sc = 20.0 + fi * 18.0;
        vec2 q = p * sc + vec2(t * (0.4 + 0.25 * fi), t * 0.1) + fi * 9.0;
        vec2 c = particle_cell(q, 0.12 + 0.05 * (3.0 - fi) / 3.0, 0.9);
        vec3 tint = hsv2rgb(vec3(fract(c.y * 3.7 + 0.55), 0.45, 1.0));
        col += tint * c.x * step(0.55, c.y) * twinkle(c.y, t * 1.5) * (1.0 - fi * 0.1);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
