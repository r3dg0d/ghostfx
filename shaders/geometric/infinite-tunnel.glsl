// @id infinite-tunnel
// @name Infinite Tunnel
// @category geometric
// @description The classic demoscene tunnel: a twisting checkerboard tube rushing toward a vanishing point.
// @tags tunnel, demoscene, checkerboard, retro, hypnotic
// @mode background
// @uses color
// @color PRIMARY #FF7A3D
// @color SECONDARY #050307
// @color ACCENT #3DA5FF
// @param SEGMENTS float 12.0 4.0 32.0 Checker segments around the tube

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.2 * sin(t * 0.3), 0.08 * cos(t * 0.4));
    float r = length(c);
    float a = atan(c.y, c.x);
    float depth = 0.3 / max(r, 1e-3) + t * 0.8;
    float n = floor(P_SEGMENTS);
    // Integer segment count keeps the angular texture seamless.
    float u = a / 6.2831 * n + depth * 0.6;
    float check = mod(floor(u) + floor(depth * 2.0), 2.0);
    vec3 col = mix(GFX_PRIMARY, GFX_ACCENT, check);
    float fog = smoothstep(0.0, 0.4, r);
    col *= fog * (0.55 + 0.45 * smoothstep(0.0, 0.2, min(fract(u), 1.0 - fract(u)) * 2.0));
    col = mix(GFX_SECONDARY, col, 0.85);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
