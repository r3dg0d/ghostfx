// @id ice-glass
// @name Ice Glass
// @category glass
// @description Frost crystals creep in from the corners of an icy pane, feathery and glittering, then slowly melt back.
// @tags ice, frost, glass, winter, crystal, blue
// @mode background
// @uses voronoi fbm hash
// @color PRIMARY #D8F3FF
// @color SECONDARY #08131E
// @color ACCENT #6FB7E8
// @param CYCLE float 40.0 10.0 120.0 Seconds for frost to grow and recede

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Growth front from the nearest corner, breathing over the cycle.
    vec2 cu = min(uv, 1.0 - uv) * vec2(gfx_aspect(), 1.0);
    float corner = length(cu);
    float grow = 0.35 + 0.25 * sin(t / P_CYCLE * 6.2831);
    float front = corner + 0.15 * fbm(p * 4.0) ;
    float frost = smoothstep(grow, grow - 0.15, front);

    // Feathery dendrites: ridged noise along cell edges.
    vec3 v = voronoi(p * 12.0, 0.0);
    float edge = 1.0 - smoothstep(0.0, 0.08, v.y - v.x);
    float fern = pow(ridged(p * 10.0 + v.z), 3.0);
    float crystal = max(edge * 0.6, fern) * frost;
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.08;
    col = mix(col, GFX_ACCENT * 0.5, frost * 0.5);
    col += GFX_PRIMARY * crystal * 0.6;
    float glitter = step(0.985, hash12(floor(fragCoord / (2.0 * gfx_dpi())))) * frost * (0.5 + 0.5 * sin(t * 4.0 + v.z * 30.0));
    col += vec3(1.0) * glitter * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
