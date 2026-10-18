// @id hyperspace-jump
// @name Hyperspace Jump
// @category space
// @description Inside the hyperspace tunnel: swirling blue-white walls of light rush by around a bright point far ahead.
// @tags hyperspace, tunnel, blue, speed, sci-fi
// @mode background
// @uses fbm value
// @color PRIMARY #7FB2FF
// @color SECONDARY #01030B
// @color ACCENT #FFFFFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.3, 0.02);
    float r = length(c);
    float z = 0.15 / max(r, 0.01) + t * 2.0;
    vec2 dir = gfx_rot(z * 0.15) * (c / max(r, 1e-4));
    // Long streaks: noise stretched along depth, seamless around the tunnel.
    float s = fbm3(vec3(dir * 4.0, z * 0.15));
    float streaks = pow(vnoise3(vec3(dir * 25.0, z * 0.05)), 3.0);
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, smoothstep(0.3, 0.8, s)) * smoothstep(0.03, 0.35, r);
    col += GFX_ACCENT * streaks * 0.8 * smoothstep(0.05, 0.4, r);
    col += GFX_ACCENT * exp(-r * 15.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
