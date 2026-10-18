// @id sunset
// @name Sunset
// @category nature
// @description A warm sun sinks into a calm sea, painting the undersides of the clouds pink and laying a golden path on the water.
// @tags sunset, sea, warm, sky, golden-hour, calm
// @mode background
// @uses fbm hash
// @color PRIMARY #FF8C42
// @color SECONDARY #2B1B3D
// @color ACCENT #FF5E8A

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = -0.1;
    vec2 sun = vec2(-0.3, hy + 0.06 + 0.02 * sin(t * 0.02));
    vec3 col;
    if (p.y > hy) {
        float y = p.y - hy;
        col = mix(GFX_PRIMARY, GFX_SECONDARY, smoothstep(0.0, 0.5, y));
        col = mix(col, GFX_ACCENT, exp(-y * 8.0) * 0.4);
        float sd = length(p - sun);
        col += GFX_PRIMARY * (0.5 * exp(-sd * 7.0) + 0.25 * exp(-sd * 2.5));
        col = mix(col, vec3(1.0, 0.85, 0.6), smoothstep(0.07, 0.065, sd));
        // Clouds lit from below.
        float cl = fbm(vec2(p.x * 1.6 + t * 0.008, y * 7.0));
        float cm = smoothstep(0.5, 0.75, cl) * smoothstep(0.05, 0.2, y);
        vec3 cc = mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(0.3, 0.0, y)) * (0.6 + 0.4 * exp(-length(p - sun)));
        col = mix(col, cc, cm * 0.8);
    } else {
        float dy = hy - p.y;
        col = mix(GFX_SECONDARY * 1.2, GFX_SECONDARY * 0.5, smoothstep(0.0, 0.4, dy));
        // Sun path: horizontal glints whose width grows toward the viewer.
        float width = 0.04 + dy * 0.6;
        float path = exp(-pow((p.x - sun.x) / width, 2.0));
        // Glints: short horizontal dashes on a fine grid (no blocky cells).
        vec2 g = vec2(p.x * 45.0 + 0.5 * sin(p.y * 90.0 + t), p.y * 260.0 + t * 1.5);
        float glint = step(0.55, hash12(floor(g))) * smoothstep(0.5, 0.15, abs(fract(g.y) - 0.5)) * smoothstep(0.5, 0.3, abs(fract(g.x) - 0.5));
        col += GFX_PRIMARY * path * (0.2 + 0.8 * glint);
        col += GFX_ACCENT * 0.1 * exp(-dy * 10.0);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
