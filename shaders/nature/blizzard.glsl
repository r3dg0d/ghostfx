// @id blizzard
// @name Blizzard
// @category nature
// @description Wind-driven snow streaks sideways through a white-out, visibility rising and falling with each gust.
// @tags snow, blizzard, winter, storm, white, intense
// @mode background
// @uses hash value
// @color PRIMARY #F2F7FF
// @color SECONDARY #3E4A5C
// @color ACCENT #8C9BB0
// @param WIND float 2.5 0.5 6.0 Wind strength

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float gust = 0.5 + 0.5 * vnoise(vec2(t * 0.4, 0.0));
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT, 0.3 + 0.4 * gust);
    // Whiteout haze swirls.
    float haze = vnoise(vec2(p.x * 3.0 - t * P_WIND * 0.3, p.y * 2.0)) * vnoise(vec2(p.x * 1.5 - t * P_WIND * 0.2, p.y + 3.0));
    col = mix(col, GFX_PRIMARY * 0.8, haze * gust * 0.5);
    vec2 dir = normalize(vec2(P_WIND, -1.0));
    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float depth = 1.0 + fi * 0.8;
        vec2 q = gfx_rot(atan(dir.y, dir.x)) * p;
        q = vec2(q.x * 6.0 * depth + t * P_WIND * 3.0 / sqrt(depth), q.y * 30.0 * depth) + fi * 7.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.25) continue;
        vec2 f = fract(q) - 0.5;
        float streak = smoothstep(0.5, 0.0, abs(f.x)) * smoothstep(0.35, 0.0, abs(f.y));
        col += GFX_PRIMARY * streak * (0.7 / depth);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
