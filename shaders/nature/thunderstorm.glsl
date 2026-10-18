// @id thunderstorm
// @name Thunderstorm
// @category nature
// @description A storm front over dark hills: heavy clouds, grey veils of rain sweeping across, and distant bolts striking the ground.
// @tags storm, thunder, rain, clouds, landscape, dramatic
// @mode background
// @uses fbm hash sdf gradient
// @flashing true
// @color PRIMARY #D5DCF0
// @color SECONDARY #0B0D12
// @color ACCENT #4A5163

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float slot = floor(t / 4.0);
    float lt = mod(t, 4.0);
    float strike = step(0.4, hash11(slot)) * exp(-lt * 7.0) * step(0.0, lt);
    strike = gfx_flash(strike);

    float cloud = fbm(vec2(p.x * 1.5 + t * 0.06, p.y * 2.5)) ;
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT, cloud * smoothstep(-0.1, 0.4, p.y));
    col += GFX_PRIMARY * strike * cloud * 0.6 * smoothstep(-0.1, 0.4, p.y);
    // Distant bolt.
    float bx = (hash11(slot + 1.3) - 0.5) * gfx_aspect() * 0.8;
    if (p.y < 0.1 && p.y > -0.3) {
        float x = bx + gnoise(vec2(p.y * 14.0, slot)) * 0.03 + gnoise(vec2(p.y * 50.0, slot)) * 0.008;
        col += GFX_PRIMARY * (smoothstep(0.002, 0.0, abs(p.x - x)) + glow(abs(p.x - x), 0.003) * 0.3) * strike * 2.0;
    }
    // Rain veils sweeping diagonally.
    float veil = fbm(vec2((p.x + p.y * 0.3) * 4.0 - t * 0.4, p.y * 0.5));
    col = mix(col, GFX_ACCENT * 0.8, smoothstep(0.45, 0.8, veil) * 0.35 * smoothstep(0.2, -0.3, p.y));
    // Hills.
    float hill = -0.3 + 0.06 * fbm(vec2(p.x * 2.0, 1.0));
    col = mix(col, GFX_SECONDARY * 0.6 + GFX_PRIMARY * strike * 0.05, smoothstep(0.003, 0.0, p.y - hill));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
