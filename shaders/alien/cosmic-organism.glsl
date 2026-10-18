// @id cosmic-organism
// @name Cosmic Organism
// @category alien
// @description Translucent bioluminescent cells drift and jostle, each with a glowing membrane and pulsing nucleus.
// @tags organic, cells, bioluminescent, alien, flowing
// @mode background
// @uses voronoi gradient
// @color PRIMARY #FF5FD2
// @color SECONDARY #06030C
// @color ACCENT #5FFFE4

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = p * 4.0 + 0.3 * vec2(gnoise(p * 2.0 + t * 0.1), gnoise(p * 2.0 - t * 0.1 + 3.0));
    vec3 v = voronoi(q, t * 0.4);
    float membrane = smoothstep(0.18, 0.0, v.y - v.x);
    float nucleus = smoothstep(0.2, 0.0, v.x - 0.05 * sin(t * 2.0 + v.z * 20.0));
    vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, v.z);
    vec3 col = GFX_SECONDARY + c * 0.05;
    col += c * membrane * 0.45;
    col += mix(c, vec3(1.0), 0.3) * nucleus * (0.4 + 0.3 * sin(t * 1.5 + v.z * 30.0));
    col += c * (1.0 - v.x) * 0.06;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
