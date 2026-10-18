// @id blueprint
// @name Blueprint
// @category geometric
// @description Engineering blueprint paper: a fine cyan grid on deep blue, with circles, arcs and dimension lines drafting themselves in white.
// @tags blueprint, technical, drawing, grid, blue, engineering
// @mode background
// @uses sdf hash
// @color PRIMARY #E8F2FF
// @color SECONDARY #0A2A5C
// @color ACCENT #4FA3E8
// @param CYCLE float 20.0 6.0 60.0 Seconds per drawing

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    vec3 col = GFX_SECONDARY;
    col += GFX_ACCENT * (grid_lines(p * 40.0, 1.0) * 0.12 + grid_lines(p * 8.0, 1.2) * 0.2);
    vec2 c = p - vec2(0.42, 0.0);
    float ang = atan(c.y, c.x);
    float r = length(c);
    float px = 1.5 * gfx_pxsize();
    // Circles drawn progressively (arc length revealed with time).
    float lines = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float R = 0.08 + fi * 0.07;
        float reveal = clamp(k * 3.0 - fi * 0.4, 0.0, 1.0);
        float drawn = step(fract(ang / 6.2831 + 0.5), reveal);
        lines += smoothstep(px, 0.0, abs(r - R)) * drawn;
    }
    // Centre lines and a dimension line with arrow ticks.
    float cl = clamp(k * 2.0, 0.0, 1.0);
    lines += smoothstep(px, 0.0, abs(c.y)) * step(abs(c.x), 0.3 * cl) * step(0.5, fract(c.x * 30.0));
    lines += smoothstep(px, 0.0, abs(c.x)) * step(abs(c.y), 0.3 * cl) * step(0.5, fract(c.y * 30.0));
    vec2 dl = c - vec2(0.0, -0.3);
    float dim = clamp(k * 3.0 - 1.5, 0.0, 1.0);
    lines += smoothstep(px, 0.0, abs(dl.y)) * step(abs(dl.x), 0.22 * dim);
    lines += smoothstep(px, 0.0, abs(abs(dl.x) - 0.22)) * step(abs(dl.y), 0.02) * step(0.999, dim);
    col += GFX_PRIMARY * min(lines, 1.0) * 0.8 * (1.0 - smoothstep(0.92, 1.0, k));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
