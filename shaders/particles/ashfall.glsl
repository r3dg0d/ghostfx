// @id ashfall
// @name Ashfall
// @category particles
// @description Grey volcanic ash flutters down through a smoky, ember-tinted sky.
// @tags ash, volcano, particles, grey, moody
// @mode background
// @uses hash fbm
// @color PRIMARY #B8B0A8
// @color SECONDARY #17110F
// @color ACCENT #6B2A12

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float haze = fbm(p * 1.4 + vec2(t * 0.03, -t * 0.02));
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.7, smoothstep(0.2, -0.7, p.y) * 0.6 + haze * 0.25);

    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float sc = 7.0 + fi * 6.0;
        vec2 q = p * sc + vec2(t * 0.15, t * (0.5 - 0.05 * fi)) + fi * 19.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.4) continue;
        vec2 f = fract(q) - 0.5;
        f.x += 0.25 * sin(t * 2.0 + hash12(id + 4.0) * 30.0);
        f = gfx_rot(t * 1.5 + hash12(id) * 9.0) * f;
        // Irregular flake: a noisy blob thresholded per cell.
        float blob = length(f * vec2(1.0, 1.8)) - 0.09 * (0.6 + vnoise(f * 18.0 + id));
        float a = smoothstep(0.02, 0.0, blob);
        col = mix(col, GFX_PRIMARY * (0.45 + 0.4 * hash12(id + 8.0)) * (1.0 - fi * 0.12), a * (0.9 - fi * 0.1));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
