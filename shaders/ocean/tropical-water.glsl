// @id tropical-water
// @name Tropical Water
// @category ocean
// @description Looking down on a turquoise lagoon: sandy shallows, rippling caustics, foam lapping at the shore and sun sparkles.
// @tags ocean, tropical, turquoise, beach, bright, summer
// @mode background
// @uses fbm voronoi particles
// @color PRIMARY #22C7C0
// @color SECONDARY #0A5F96
// @color ACCENT #F2E3BF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Depth increases from the bottom-left beach toward the top-right.
    float shore = 0.08 * sin(t * 0.5) + 0.03 * sin(p.x * 7.0 + t);
    float s = (p.x * 0.45 + p.y) - shore + 0.12 * fbm(p * 2.0);
    float depth = smoothstep(-0.45, 0.6, s);

    vec3 sand = GFX_ACCENT * (0.85 + 0.15 * vnoise(p * 60.0));
    vec3 water = mix(GFX_PRIMARY, GFX_SECONDARY, smoothstep(0.15, 1.0, depth));
    vec3 col = mix(sand, water, smoothstep(-0.02, 0.2, depth));

    // Caustics are strongest in the shallows.
    vec3 v = voronoi(p * 9.0, t * 1.2);
    float c = 1.0 - smoothstep(0.0, 0.15, v.y - v.x);
    col += vec3(1.0) * c * 0.35 * (1.0 - depth) * smoothstep(-0.02, 0.1, depth);

    // Foam band along the moving waterline.
    float foam = smoothstep(0.06, 0.0, abs(depth - 0.03)) * (0.5 + 0.5 * vnoise(p * 30.0 + t));
    col = mix(col, vec3(1.0), foam * 0.8);

    // Sun sparkles on the surface.
    vec2 sp = particle_cell(p * 55.0 + vec2(t * 0.6, 0.0), 0.2, 0.8);
    float sparkle = sp.x * step(0.9, sp.y) * pow(0.5 + 0.5 * sin(t * 6.0 + sp.y * 50.0), 6.0);
    col += vec3(1.0) * sparkle * smoothstep(0.1, 0.4, depth);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
