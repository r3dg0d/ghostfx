// @id fireflies
// @name Fireflies
// @category particles
// @description Fireflies wander over a dusky meadow, each blinking on its own slow rhythm above silhouetted grass.
// @tags particles, fireflies, nature, night, cozy, green
// @mode background
// @uses hash fbm
// @color PRIMARY #D8FF6A
// @color SECONDARY #06120F
// @color ACCENT #1E3B2C
// @param COUNT int 28 6 60 Number of fireflies

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.6, smoothstep(0.6, -0.5, p.y));
    // Grass silhouette.
    float sway = 0.3 * sin(t * 0.8 + p.x * 3.0);
    float blades = 0.03 + 0.06 * vnoise(vec2(p.x * 160.0 + sway, 0.0)) + 0.05 * vnoise(vec2(p.x * 23.0, 1.0));
    col = mix(col, vec3(0.0, 0.015, 0.01), smoothstep(0.004, 0.0, p.y + 0.42 - blades));

    float A = gfx_aspect();
    for (int i = 0; i < P_COUNT; i++) {
        float fi = float(i);
        vec2 h = hash22(vec2(fi, 4.2));
        vec2 h2 = hash22(vec2(fi, 9.7));
        // Lissajous wander with per-firefly frequencies.
        vec2 pos = vec2((h.x - 0.5) * A + 0.18 * sin(t * (0.13 + 0.2 * h2.x) + fi),
                        (h.y - 0.6) * 0.8 + 0.12 * sin(t * (0.17 + 0.2 * h2.y) + fi * 2.3));
        float blink = pow(max(sin(t * (0.6 + h2.x) + fi * 4.0), 0.0), 3.0);
        float d = length(p - pos);
        col += GFX_PRIMARY * blink * (0.003 / (d * d + 0.0004) * 0.25 + smoothstep(0.006, 0.0, d));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
