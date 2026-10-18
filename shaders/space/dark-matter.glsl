// @id dark-matter
// @name Dark Matter
// @category space
// @description Invisible halos of dark matter drift through a field of distant galaxies, revealed only by the arcs they bend them into.
// @tags space, dark-matter, lensing, galaxies, subtle
// @mode background
// @uses hash
// @color PRIMARY #C8D4FF
// @color SECONDARY #020309
// @color ACCENT #FFB98A

vec3 galaxies(vec2 q) {
    vec2 g = q * 18.0;
    vec2 id = floor(g);
    vec2 f = fract(g) - 0.5;
    float h = hash12(id);
    if (h > 0.35) return vec3(0.0);
    vec2 o = (hash22(id) - 0.5) * 0.5;
    vec2 d = gfx_rot(h * 6.28) * (f - o);
    float e = length(d * vec2(1.0, 2.0 + 2.0 * hash12(id + 3.0)));
    vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, hash12(id + 7.0));
    return c * exp(-e * e * 400.0) * 0.8;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Sum of point-lens deflections from three slowly moving halos.
    vec2 q = p;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * (0.03 + 0.01 * fi) + fi * 2.0) * 0.6, cos(t * (0.025 + 0.01 * fi) + fi * 1.3) * 0.3);
        vec2 d = p - c;
        float b = 0.08 + 0.03 * fi;
        q -= d / max(dot(d, d), 1e-3) * b * b;
    }
    vec3 col = GFX_SECONDARY + galaxies(q) + galaxies(q * 1.7 + 3.0) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
