// @id rusted-steel
// @name Rusted Steel
// @category metallic
// @description Weathered steel plate: orange rust blooms, pitting and streaks that run down from rivets, creeping slowly over time.
// @tags rust, steel, industrial, weathered, orange
// @mode background
// @uses fbm hash
// @color PRIMARY #A8481C
// @color SECONDARY #3A3D40
// @color ACCENT #6E2C10
// @param RIVETS float 1.0 0.0 1.0 Show rivet rows

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 steel = GFX_SECONDARY * (0.8 + 0.3 * fbm(p * vec2(4.0, 30.0)));
    float creep = 0.6 + 0.08 * sin(t * 0.05);
    float rust = smoothstep(creep, creep + 0.2, fbm(p * 2.5) + 0.25 * fbm(p * 10.0));
    // Streaks running down from the top edge and rivets.
    float streak = fbm(vec2(p.x * 40.0, p.y * 1.5)) * smoothstep(-0.6, 0.5, p.y);
    rust = max(rust, smoothstep(0.55, 0.8, streak) * 0.7);
    vec3 rc = mix(GFX_ACCENT, GFX_PRIMARY, fbm(p * 8.0));
    rc *= 0.7 + 0.5 * hash12(floor(fragCoord / (2.0 * gfx_dpi())));
    vec3 col = mix(steel, rc, rust);
    // Rivets along the top and bottom.
    if (P_RIVETS > 0.5) {
        vec2 rg = vec2(fract(p.x * 5.0) - 0.5, abs(p.y) - 0.44);
        float rv = smoothstep(0.025, 0.018, length(vec2(rg.x / 5.0, rg.y)));
        col = mix(col, steel * 1.3 + vec3(0.1) * step(0.0, rg.y), rv);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
