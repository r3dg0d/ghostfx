// @id voronoi
// @name Voronoi
// @category geometric
// @description Softly coloured Voronoi cells drift and reshape, their borders glowing where neighbours meet.
// @tags voronoi, cells, geometric, colorful, calm
// @mode background
// @uses voronoi color
// @color PRIMARY #5B6CFF
// @color SECONDARY #07080F
// @color ACCENT #FF6B9D
// @param SCALE float 5.0 2.0 14.0 Cells per screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = p * P_SCALE;
    vec3 v = voronoi(q, t * 0.5);
    float e = voronoi_edge(q, t * 0.5);
    vec3 cell = mix(GFX_PRIMARY, GFX_ACCENT, v.z) * (0.25 + 0.25 * sin(t * 0.5 + v.z * 6.28));
    vec3 col = GFX_SECONDARY + cell * (1.0 - v.x * 0.6);
    col += mix(GFX_PRIMARY, GFX_ACCENT, v.z) * smoothstep(0.04, 0.0, e) * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
