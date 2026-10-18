// @id psychedelic-waves
// @name Psychedelic Waves
// @category liquid
// @description Saturated bands of colour pour and fold through each other in hypnotic interference patterns.
// @tags psychedelic, colorful, waves, trippy, rainbow
// @mode background
// @uses gradient color
// @color PRIMARY #FF3D7F
// @color SECONDARY #12001F
// @color ACCENT #3DFFB5
// @param HUE_SPEED float 0.05 0.0 0.5 Palette cycling speed

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 2.0;
    float t = gfx_time();
    vec2 w = p;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        w += 0.35 * vec2(sin(w.y * (1.5 + fi) + t * 0.4 + fi), cos(w.x * (1.3 + fi) - t * 0.3));
    }
    float v = sin(w.x * 2.0) + sin(w.y * 2.0) + sin(length(w) * 3.0 - t);
    float b = fract(v * 0.35 + t * P_HUE_SPEED);
    vec3 col = cospal(b, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    col = mix(col, mix(GFX_PRIMARY, GFX_ACCENT, b), 0.35);
    col *= 0.75 + 0.25 * sin(v * 6.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col * 0.85);
}
