// @id neon-grid
// @name Neon Grid
// @category cyberpunk
// @description An endless glowing grid floor rushes toward you under a dark horizon haze, pure retro-futurism.
// @tags grid, neon, retro, 80s, perspective
// @mode background
// @uses sdf
// @color PRIMARY #FF2BD6
// @color SECONDARY #05020C
// @color ACCENT #2BD9FF
// @param HORIZON float 0.05 -0.3 0.3 Horizon height
// @param SPEED_GRID float 1.0 0.0 4.0 Floor speed

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = P_HORIZON;
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * 0.25 * exp(-abs(p.y - hy) * 8.0);
    if (p.y < hy) {
        float dy = hy - p.y;
        float z = 0.25 / dy;
        vec2 g = vec2(p.x * z, z + t * P_SPEED_GRID * 0.25) * 16.0;
        float line = grid_lines(g, 1.5 * gfx_dpi());
        float fade = exp(-z * 0.25);
        col += mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(0.0, 0.3, dy)) * line * fade * 1.2;
        col += GFX_PRIMARY * 0.08 * fade;
    } else {
        // Thin horizon band glow above.
        col += GFX_ACCENT * 0.15 * exp(-(p.y - hy) * 20.0);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
