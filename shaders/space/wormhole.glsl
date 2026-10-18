// @id wormhole
// @name Wormhole
// @category space
// @description Falling down a tunnel through spacetime: nebular walls stream past toward a bright far opening.
// @tags space, wormhole, tunnel, warp, colorful
// @mode background
// @uses fbm value
// @color PRIMARY #6A5CFF
// @color SECONDARY #020108
// @color ACCENT #2EE6D6
// @param TWIST float 0.6 0.0 2.0 Tunnel twist

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.25, 0.0);
    float r = length(c);
    float depth = 0.25 / max(r, 0.02) + t * 0.8;
    // Angle encoded as a direction vector: seamless around the tunnel.
    vec2 dir = gfx_rot(depth * P_TWIST * 0.3) * (c / max(r, 1e-4));
    float n = fbm3(vec3(dir * 1.5, depth * 0.6));
    float streak = vnoise3(vec3(dir * 6.0, depth * 3.0));
    vec3 col = mix(GFX_PRIMARY, GFX_ACCENT, n) * pow(n, 1.5) * 1.4;
    col += vec3(1.0) * pow(streak, 6.0) * 0.6;
    col *= smoothstep(0.02, 0.35, r);
    col += mix(GFX_ACCENT, vec3(1.0), 0.5) * exp(-r * 18.0) * 1.2;
    col = mix(GFX_SECONDARY, col, smoothstep(1.2, 0.3, r) * 0.8 + 0.2);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
