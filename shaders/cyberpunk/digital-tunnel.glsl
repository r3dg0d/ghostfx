// @id digital-tunnel
// @name Digital Tunnel
// @category cyberpunk
// @description Racing down a square data tunnel: grid-lined walls, rushing light streaks and a glowing exit far ahead.
// @tags tunnel, cyber, grid, speed, data
// @mode background
// @uses hash
// @color PRIMARY #00F0FF
// @color SECONDARY #020309
// @color ACCENT #FF3BD1
// @param SPEED_TUNNEL float 1.0 0.0 4.0 Travel speed

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Square tunnel: Chebyshev "radius"; depth = 1/r.
    float r = max(abs(p.x) / gfx_aspect() * 1.2, abs(p.y)) + 1e-3;
    float z = 0.2 / r + t * P_SPEED_TUNNEL;
    // Coordinate around the wall perimeter (continuous).
    vec2 q = p / r;
    float around = abs(q.y) > abs(q.x) / gfx_aspect() * 1.2 ? q.x : q.y;
    vec2 g = vec2(around * 4.0, z * 2.0);
    vec2 gl = abs(fract(g) - 0.5);
    float line = max(smoothstep(0.45, 0.5, gl.x), smoothstep(0.47, 0.5, gl.y));
    float fade = smoothstep(0.0, 0.25, r);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * line * fade * 0.6;
    // Data streaks travelling along the walls.
    vec2 sid = vec2(floor(around * 12.0), floor(z * 0.5));
    float streak = step(0.85, fract(z * 0.5 * 4.0 + hash12(vec2(sid.x, 1.0)) * 4.0)) * step(0.7, hash12(sid));
    col += mix(GFX_PRIMARY, GFX_ACCENT, hash12(sid)) * streak * fade * 0.8;
    col += mix(GFX_ACCENT, vec3(1.0), 0.3) * exp(-r * 25.0) * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
