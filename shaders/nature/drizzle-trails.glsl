// @id drizzle-trails
// @name Drizzle Trails
// @category nature
// @description Fine, wind-blown drizzle: thin luminous streaks with long trailing tails slant across a soft grey evening.
// @tags rain, drizzle, streaks, calm, grey, weather
// @mode background
// @uses hash
// @color PRIMARY #CFE0F2
// @color SECONDARY #12161C
// @color ACCENT #5C6E85
// @param SLANT float 0.35 -1.0 1.0 Wind slant

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.5, smoothstep(0.6, -0.6, p.y));
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = vec2(p.x + p.y * P_SLANT, p.y);
        q = vec2(q.x * (40.0 + fi * 25.0), q.y * (1.2 + fi * 0.4) + t * (1.6 + fi * 0.5)) + fi * 5.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.18) continue;
        float fy = fract(q.y);
        float head = smoothstep(0.03, 0.0, abs(fy - 0.9));
        float tail = smoothstep(0.0, 0.9, fy) * step(fy, 0.9);
        float w = smoothstep(0.25, 0.0, abs(fract(q.x) - 0.5));
        col += GFX_PRIMARY * w * (tail * 0.15 + head * 0.5) * (0.8 - fi * 0.2);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
