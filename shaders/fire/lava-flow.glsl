// @id lava-flow
// @name Lava Flow
// @category fire
// @description Slow rivers of molten rock: dark cooling crust plates drift apart over glowing orange cracks.
// @tags lava, molten, volcano, slow, orange
// @mode background
// @uses voronoi fbm
// @color PRIMARY #FF5B00
// @color SECONDARY #140603
// @color ACCENT #FFD166
// @param FLOW float 1.0 0.0 3.0 Flow speed of the crust

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec2 q = p * 4.0;
    q.x -= t * 0.12 * P_FLOW;
    q += 0.4 * vec2(fbm(q * 0.5 + t * 0.03), fbm(q * 0.5 + 4.0));
    vec3 v = voronoi(q, t * 0.15);
    float crack = 1.0 - smoothstep(0.0, 0.06 + 0.08 * vnoise(q * 3.0), v.y - v.x);
    float pulse = 0.75 + 0.25 * sin(t * 0.8 + v.z * 6.0);
    float crust = 0.5 + 0.5 * fbm(q * 2.0 + v.z * 10.0);

    vec3 col = GFX_SECONDARY * (0.6 + crust * 0.8);
    vec3 glowc = mix(GFX_PRIMARY, GFX_ACCENT, crack * crack);
    col += glowc * crack * pulse * 1.3;
    col += GFX_PRIMARY * 0.12 * (1.0 - smoothstep(0.0, 0.5, v.y - v.x));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
