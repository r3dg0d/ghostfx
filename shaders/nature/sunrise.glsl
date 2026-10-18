// @id sunrise
// @name Sunrise
// @category nature
// @description Dawn breaks over rolling hills: the sky warms from deep blue to gold as the sun slowly climbs, again and again.
// @tags sunrise, dawn, sky, warm, hills, calm
// @mode background
// @uses fbm
// @color PRIMARY #FFB347
// @color SECONDARY #0E1A3A
// @color ACCENT #FF6F61
// @param CYCLE float 90.0 20.0 600.0 Seconds for one sunrise

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);                        // 0 = pre-dawn, 1 = morning
    float sunY = -0.35 + k * 0.6;
    vec2 sun = vec2(0.35, sunY);
    float horizon = -0.18;
    float warm = smoothstep(-0.4, 0.1, sunY);
    vec3 top = mix(GFX_SECONDARY, vec3(0.35, 0.55, 0.85), smoothstep(0.0, 0.25, sunY));
    vec3 low = mix(GFX_ACCENT * 0.4, GFX_PRIMARY, warm);
    vec3 col = mix(low, top, smoothstep(horizon, 0.5, p.y));
    float sd = length(p - sun);
    col += GFX_PRIMARY * (0.6 * exp(-sd * 6.0) + 0.3 * exp(-sd * 2.0)) * warm;
    col = mix(col, vec3(1.0, 0.95, 0.8), smoothstep(0.045, 0.04, sd));
    // Thin lit clouds.
    float cl = fbm(vec2(p.x * 2.0 + t * 0.01, p.y * 8.0));
    col = mix(col, mix(GFX_ACCENT, GFX_PRIMARY, warm) * 0.9, smoothstep(0.55, 0.8, cl) * smoothstep(0.0, 0.3, p.y) * 0.5);
    // Two hill layers.
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        float h = horizon - fi * 0.1 + 0.06 * fbm(vec2(p.x * (1.5 + fi), fi * 4.0));
        vec3 hc = mix(vec3(0.05, 0.05, 0.1), mix(vec3(0.15, 0.1, 0.15), vec3(0.08, 0.06, 0.08), fi), warm * (1.0 - fi));
        col = mix(col, hc, smoothstep(0.003, 0.0, p.y - h));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
