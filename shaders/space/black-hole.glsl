// @id black-hole
// @name Black Hole
// @category space
// @description A black hole bends the starfield and nebula behind it into an Einstein ring around a perfectly dark shadow.
// @tags space, black-hole, lensing, gravity, dark
// @mode background
// @uses fbm hash
// @color PRIMARY #FFB46B
// @color SECONDARY #020208
// @color ACCENT #6E8BFF
// @param SIZE float 0.12 0.04 0.3 Shadow radius
// @param X float 0.35 -0.8 0.8 Horizontal position

vec3 sky(vec2 q, float t) {
    vec3 c = GFX_SECONDARY;
    float n = fbm(q * 1.2 + vec2(t * 0.01, 0.0));
    c += mix(GFX_ACCENT, GFX_PRIMARY, fbm(q * 0.7 + 5.0)) * pow(n, 3.0) * 0.4;
    vec2 g = q * 40.0;
    vec2 id = floor(g);
    float s = step(0.93, hash12(id)) * smoothstep(0.25, 0.0, length(fract(g) - 0.5 - (hash22(id) - 0.5) * 0.5));
    return c + vec3(s);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(P_X, 0.05);
    float r = length(c);
    float rs = P_SIZE;
    // Thin-lens deflection: points near the ring map far away (Einstein ring).
    float b = rs * 1.3;
    vec2 lensed = c - c / max(r * r, 1e-4) * b * b;
    vec3 col = sky(lensed + vec2(P_X, 0.05), t);
    float ring = exp(-pow((r - b) / (rs * 0.06), 2.0));
    col += mix(GFX_PRIMARY, vec3(1.0), 0.5) * ring * 0.8;
    col += GFX_PRIMARY * 0.12 * exp(-(r - rs) * 8.0) * step(rs, r);
    col *= smoothstep(rs * 0.98, rs * 1.02, r);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
