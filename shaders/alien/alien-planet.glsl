// @id alien-planet
// @name Alien Planet
// @category alien
// @description A teal-and-rose alien sky with two moons and a ringed giant, above layered jagged ridges and drifting spores.
// @tags alien, planet, landscape, sky, moons, surreal
// @mode background
// @uses fbm hash
// @color PRIMARY #2EC4B6
// @color SECONDARY #1A0B2E
// @color ACCENT #FF8FB1

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec3 col = mix(GFX_ACCENT * 0.7, GFX_SECONDARY, smoothstep(-0.2, 0.5, p.y));
    col = mix(col, GFX_PRIMARY * 0.6, smoothstep(0.1, -0.2, p.y) * 0.5);
    // Ringed giant.
    vec2 g = p - vec2(-0.45, 0.22);
    float gd = length(g);
    col = mix(col, mix(GFX_PRIMARY, GFX_SECONDARY, 0.4 + 0.3 * sin(g.y * 60.0 + fbm(g * 8.0) * 3.0)), smoothstep(0.17, 0.165, gd));
    vec2 rg = gfx_rot(0.35) * g;
    float ring = smoothstep(0.012, 0.0, abs(length(rg * vec2(1.0, 4.0)) - 0.26)) * step(0.0, rg.y + (gd > 0.17 ? 1.0 : 0.0) - 0.0001 * 0.0);
    col = mix(col, GFX_ACCENT, ring * 0.7 * step(0.17, gd) + ring * 0.7 * step(rg.y, 0.0) * step(gd, 0.17));
    // Two small moons.
    col = mix(col, vec3(0.95, 0.9, 1.0), smoothstep(0.03, 0.028, length(p - vec2(0.35, 0.33))));
    col = mix(col, GFX_ACCENT, smoothstep(0.018, 0.016, length(p - vec2(0.5 + 0.02 * sin(t * 0.05), 0.25))));
    // Three parallax ridges.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float x = p.x + t * 0.01 * (fi + 1.0);
        float hgt = -0.05 - fi * 0.12 + 0.15 * ridged(vec2(x * (1.5 + fi), fi * 7.0)) * (1.0 - fi * 0.2);
        vec3 rc = mix(GFX_SECONDARY * 0.6, GFX_PRIMARY * 0.25, fi / 3.0) * (1.0 - fi * 0.3);
        col = mix(col, rc, smoothstep(0.003, 0.0, p.y - hgt));
    }
    // Spores.
    vec2 s = p * 30.0 + vec2(t * 0.3, -t * 0.4);
    vec2 id = floor(s);
    float sp = step(0.96, hash12(id)) * smoothstep(0.15, 0.0, length(fract(s) - 0.5));
    col += GFX_PRIMARY * sp * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
