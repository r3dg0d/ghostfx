// @id lunar-surface
// @name Lunar Surface
// @category space
// @description Standing on the Moon: a cratered grey plain under a black sky, with a blue Earth hanging low above the horizon.
// @tags moon, lunar, craters, earth, space, landscape
// @mode background
// @uses voronoi fbm hash
// @color PRIMARY #9A9A9A
// @color SECONDARY #000000
// @color ACCENT #3D8BFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = -0.05 + 0.02 * fbm(vec2(p.x * 3.0, 0.0));
    vec3 col = GFX_SECONDARY;
    vec2 sg = p * 90.0;
    col += vec3(0.7) * step(0.993, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5));
    // Earth with a terminator and drifting clouds.
    vec2 e = p - vec2(-0.45, 0.22);
    float er = length(e);
    float lit = smoothstep(-0.02, 0.03, dot(e / 0.07, normalize(vec2(1.0, 0.3))) + 0.3);
    float land = smoothstep(0.5, 0.6, fbm(e * 30.0 + vec2(t * 0.005, 0.0)));
    float cloud = smoothstep(0.55, 0.75, fbm(e * 20.0 + vec2(t * 0.01, 3.0)));
    vec3 ec = mix(GFX_ACCENT * 0.8, vec3(0.3, 0.55, 0.25), land);
    ec = mix(ec, vec3(0.95), cloud) * lit;
    col = mix(col, ec, smoothstep(0.071, 0.069, er));
    col += GFX_ACCENT * 0.25 * exp(-(er - 0.07) * 60.0) * step(0.07, er) * lit;
    if (p.y < hy) {
        // Foreshortened ground with craters.
        float dy = hy - p.y;
        vec2 g = vec2(p.x / (dy + 0.05), 1.0 / (dy + 0.05)) * 0.6;
        vec3 v = voronoi(g * 2.0, 0.0);
        float rim = smoothstep(0.08, 0.0, abs(v.x - 0.3)) * step(0.55, v.z);
        float bowl = smoothstep(0.3, 0.0, v.x) * step(0.55, v.z);
        float grain = fbm(g * 6.0);
        vec3 gc = GFX_PRIMARY * (0.3 + 0.35 * grain) * (1.0 - bowl * 0.5) + vec3(0.25) * rim;
        col = gc * smoothstep(-0.6, hy, p.y) * 1.1;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
