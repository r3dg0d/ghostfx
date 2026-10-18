// @id waterfall
// @name Waterfall
// @category ocean
// @description A tall curtain of falling water between dark cliffs, with white streaks, spray and mist boiling up from the pool.
// @tags water, waterfall, nature, mist, motion
// @mode background
// @uses fbm particles
// @color PRIMARY #CFEAF5
// @color SECONDARY #0E1A1F
// @color ACCENT #5E8FA3
// @param WIDTH float 0.6 0.2 1.0 Width of the falls (fraction of screen height units)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Rock walls.
    float rock = fbm(p * vec2(6.0, 3.0));
    vec3 col = GFX_SECONDARY * (0.6 + 0.8 * rock);

    // Water sheet with a ragged, wavering edge.
    float edge = P_WIDTH * 0.5 * gfx_aspect() * 0.6 + 0.04 * fbm(vec2(p.y * 4.0 - t * 0.5, 1.0));
    float inside = smoothstep(edge, edge - 0.03, abs(p.x));
    vec2 q = vec2(p.x * 28.0, p.y * 1.5 + t * 2.4);
    float streak = vnoise(q) * 0.6 + vnoise(q * vec2(2.3, 1.7) + 9.0) * 0.4;
    float turb = fbm(vec2(p.x * 6.0, p.y * 2.0 + t * 1.8));
    vec3 water = mix(GFX_ACCENT * 0.7, GFX_PRIMARY, smoothstep(0.35, 0.85, streak * 0.7 + turb * 0.5));
    col = mix(col, water, inside);

    // Mist rising from the plunge pool.
    float mist = fbm(vec2(p.x * 2.5, p.y * 2.0 - t * 0.35)) * smoothstep(0.1, -0.5, p.y);
    col = mix(col, GFX_PRIMARY * 0.8, clamp(mist * 1.2, 0.0, 0.85));

    // Spray droplets.
    vec2 c = particle_cell(p * 45.0 + vec2(0.0, t * 3.0), 0.12, 0.8);
    col += GFX_PRIMARY * c.x * step(0.75, c.y) * smoothstep(0.0, -0.4, p.y) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
