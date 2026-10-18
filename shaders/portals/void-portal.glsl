// @id void-portal
// @name Void Portal
// @category portals
// @description Purple light spirals into a portal of absolute black, banded rings pulled ever inward toward nothing.
// @tags portal, void, purple, black, spiral, dark
// @mode background
// @uses fbm hash
// @color PRIMARY #8A3DFF
// @color SECONDARY #020104
// @color ACCENT #E3B8FF
// @param X float 0.4 -0.8 0.8 Portal position

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(P_X, 0.0);
    float r = length(c);
    float R = 0.11;
    // Inflowing rings: phase in log-radius drifts inward over time.
    float lr = log(r + 1e-3);
    float rings = 0.5 + 0.5 * sin(lr * 18.0 + t * 2.0);
    vec2 sw = gfx_rot(0.6 / (r + 0.05) + t * 0.5) * c;
    float n = fbm(sw * 5.0);
    float halo = exp(-(r - R) * 5.0) * step(R, r);
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_PRIMARY, GFX_ACCENT, n * rings) * halo * (0.25 + 0.75 * n * rings) * 1.2;
    col += GFX_ACCENT * exp(-abs(r - R) * 120.0) * 0.9;
    // Motes spiralling in.
    vec2 g = vec2(lr * 6.0 + t * 0.8, atan(sw.y, sw.x) / 6.2831 * 24.0);
    float m = step(0.92, hash12(vec2(floor(g.x), mod(floor(g.y), 24.0)))) * smoothstep(0.35, 0.0, length(fract(g) - 0.5));
    col += GFX_ACCENT * m * halo;
    col *= smoothstep(R * 0.95, R * 1.05, r);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
