// @id dimensional-rift
// @name Dimensional Rift
// @category portals
// @description A jagged tear in space splits the screen, glowing at its ragged edges with another dimension churning inside.
// @tags rift, portal, tear, magenta, surreal
// @mode background
// @uses fbm hash gradient
// @color PRIMARY #FF3DCB
// @color SECONDARY #050309
// @color ACCENT #6BF2FF
// @param WIDTH float 0.06 0.02 0.2 Maximum width of the tear

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Rift centre-line: a slanted jagged path; width pulses along its length.
    float x = 0.45 + p.y * 0.25 + 0.06 * gnoise(vec2(p.y * 4.0, 1.0)) + 0.02 * gnoise(vec2(p.y * 18.0, 3.0));
    float w = P_WIDTH * (0.4 + 0.6 * smoothstep(0.55, 0.0, abs(p.y))) * (0.85 + 0.15 * sin(t * 1.3 + p.y * 6.0));
    w += 0.01 * gnoise(vec2(p.y * 30.0, t * 0.5));
    float d = abs(p.x - x) - w;
    vec3 col = GFX_SECONDARY;
    if (d < 0.0) {
        vec2 q = vec2((p.x - x) / max(w, 1e-3), p.y * 3.0 - t * 0.4);
        float n = fbm(q * vec2(1.5, 1.0) + fbm(q + t * 0.2));
        col = mix(GFX_ACCENT * 0.4, GFX_PRIMARY, n) * (0.6 + 0.6 * n);
    }
    float edge = exp(-abs(d) * 160.0) + exp(-max(d, 0.0) * 25.0) * 0.25;
    col += mix(GFX_PRIMARY, vec3(1.0), 0.3) * edge * (0.8 + 0.2 * sin(t * 9.0 + p.y * 40.0));
    // Sparks leaking out of the rift.
    vec2 g = vec2((p.x - x) * 40.0 + sin(t + p.y * 9.0), p.y * 40.0 + t * 2.0);
    float sp = step(0.97, hash12(floor(g))) * smoothstep(0.3, 0.0, length(fract(g) - 0.5)) * exp(-max(d, 0.0) * 8.0);
    col += GFX_ACCENT * sp;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
