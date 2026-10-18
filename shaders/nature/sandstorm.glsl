// @id sandstorm
// @name Sandstorm
// @category nature
// @description A digital sandstorm: grains whip sideways in dense streams while ochre dust clouds roll through and swallow the light.
// @tags sand, storm, desert, wind, dust, particles
// @mode background
// @uses hash fbm
// @color PRIMARY #E8B877
// @color SECONDARY #2A1A0C
// @color ACCENT #8A5A2B
// @param WIND float 2.0 0.5 5.0 Wind speed

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float dust = fbm(vec2(p.x * 1.2 - t * P_WIND * 0.15, p.y * 2.0 + 0.2 * sin(t * 0.3)));
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.7, dust);
    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        vec2 q = vec2(p.x * (8.0 + fi * 6.0) - t * P_WIND * (2.0 + fi), p.y * (60.0 + fi * 30.0) + sin(p.x * 3.0 + fi) * 2.0);
        vec2 id = floor(q);
        float g = step(0.9, hash12(id)) * smoothstep(0.5, 0.0, abs(fract(q.y) - 0.5)) * smoothstep(0.0, 0.8, fract(q.x));
        col += GFX_PRIMARY * g * (0.18 - fi * 0.025);
    }
    col = mix(col, GFX_ACCENT * 1.2, smoothstep(0.55, 0.85, dust) * 0.5);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
