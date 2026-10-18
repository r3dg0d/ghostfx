// @id ocean-at-night
// @name Ocean at Night
// @category ocean
// @description A dark sea under a full moon, its silver glitter path breaking up across slow black swells.
// @tags ocean, night, moon, stars, calm, dark
// @mode background
// @uses gradient particles fbm
// @color PRIMARY #071A33
// @color SECONDARY #0F2C52
// @color ACCENT #E8EEFF
// @param MOON_X float 0.25 -0.8 0.8 Moon horizontal position
// @param STARS float 1.0 0.0 2.0 Star density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = 0.02;
    vec2 moon = vec2(P_MOON_X, 0.3);
    vec3 col;

    if (p.y > hy) {
        col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.5, smoothstep(0.0, 0.5, p.y - hy));
        vec2 s = particle_cell(p * 70.0, 0.12, 0.8);
        col += vec3(0.9) * s.x * step(1.0 - 0.18 * P_STARS, s.y) * twinkle(s.y, t * 2.0);
        float d = length(p - moon);
        float disc = smoothstep(0.062, 0.058, d);
        float craters = 0.82 + 0.18 * fbm((p - moon) * 30.0);
        col = mix(col, GFX_ACCENT * craters, disc);
        col += GFX_ACCENT * (0.25 * exp(-d * 9.0) + 0.1 * exp(-d * 2.5));
    } else {
        float dy = hy - p.y;
        float z = 0.25 / (dy + 0.004);
        vec2 w = vec2(p.x * z, z - t * 0.4);
        float swell = gnoise(w * 0.5 + t * 0.15) + 0.5 * gnoise(w * 1.3 - t * 0.2);
        col = mix(GFX_PRIMARY * 0.45, GFX_SECONDARY * 0.8, 0.5 + 0.5 * swell);
        // Glitter path: width grows toward the viewer, broken by wave facets.
        float width = 0.015 + 0.35 * dy;
        float path = exp(-pow((p.x - moon.x) / width, 2.0));
        vec2 g = vec2(p.x * 60.0 + 0.5 * sin(p.y * 80.0 + t), p.y * 300.0 + t * 2.0);
        float facet = step(0.6, hash12(floor(g))) * smoothstep(0.5, 0.15, abs(fract(g.y) - 0.5)) * smoothstep(0.5, 0.3, abs(fract(g.x) - 0.5))
                    * (0.6 + 0.4 * sin(t * 3.0 + hash12(floor(g)) * 30.0));
        col += GFX_ACCENT * path * (0.15 + facet * 0.9);
        col = mix(col, GFX_SECONDARY, smoothstep(10.0, 45.0, z) * 0.7);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
