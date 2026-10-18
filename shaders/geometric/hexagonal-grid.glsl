// @id hexagonal-grid
// @name Hexagonal Grid
// @category geometric
// @description Bevelled hexagon tiles rise and fall in rolling waves, their tops catching the light as the wave passes.
// @tags hexagon, grid, tiles, geometric, waves
// @mode background
// @uses sdf hash
// @color PRIMARY #3DD6C6
// @color SECONDARY #050A0C
// @color ACCENT #9B6BFF
// @param CELLS float 12.0 5.0 30.0 Hexagons per screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec4 ht = hex_tile(p * P_CELLS);
    vec2 g = ht.xy;
    vec2 cid = ht.zw / P_CELLS;
    float e = hex_edge(g);
    // Tile height from two interfering waves.
    float h = 0.5 + 0.25 * sin(length(cid - vec2(-0.5, 0.2)) * 9.0 - t * 1.4) + 0.25 * sin(cid.x * 6.0 + cid.y * 4.0 + t * 0.8);
    float bevel = smoothstep(0.38, 0.47, e);
    // Bevel shading: light from the upper left.
    vec2 dir = g / max(length(g), 1e-3);
    float lit = 0.5 + 0.5 * dot(dir, normalize(vec2(-0.6, 0.8)));
    vec3 top = mix(GFX_SECONDARY * 2.0, mix(GFX_PRIMARY, GFX_ACCENT, hash12(cid * 31.0)), h * 0.6);
    vec3 col = mix(top, top * (0.4 + 0.9 * lit), bevel);
    col *= smoothstep(0.5, 0.47, e) * 0.8 + 0.2;
    col += GFX_PRIMARY * pow(h, 6.0) * 0.4 * (1.0 - bevel);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
