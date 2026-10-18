// @id asteroid-field
// @name Asteroid Field
// @category space
// @description Lumpy, cratered asteroids tumble past on several depths, lit hard from one side against the starfield.
// @tags asteroids, space, rocks, parallax
// @mode background
// @uses hash value
// @color PRIMARY #B8AFA3
// @color SECONDARY #020205
// @color ACCENT #FFD9A0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    vec2 sg = p * 80.0;
    col += vec3(0.7) * step(0.99, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5));
    vec2 L = normalize(vec2(-0.8, 0.5));
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float sc = 2.5 + fi * 2.0;
        vec2 q = p * sc + vec2(t * (0.06 + 0.04 * fi), sin(t * 0.03 + fi) * 0.2) + fi * 9.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.45) continue;
        vec2 f = fract(q) - 0.5 - (hash22(id) - 0.5) * 0.3;
        f = gfx_rot(t * (hash12(id + 1.0) - 0.5) * 0.6) * f;
        float a = atan(f.y, f.x);
        // Lumpy outline: radius modulated by a seamless angular noise.
        float rr = 0.18 + 0.12 * hash12(id + 2.0);
        float bump = vnoise(vec2(cos(a), sin(a)) * 2.0 + id * 3.0) * 0.35 + vnoise(vec2(cos(a), sin(a)) * 5.0 + id) * 0.15;
        float d = length(f) - rr * (0.75 + bump);
        if (d > 0.0) continue;
        // Fake sphere normal for shading, plus craters.
        float h = clamp(-d / rr, 0.0, 1.0);
        vec2 n2 = normalize(f) * (1.0 - h);
        float lit = clamp(dot(n2, L) * 0.8 + 0.35, 0.05, 1.0);
        float crater = smoothstep(0.35, 0.5, vnoise(f * 18.0 + id * 7.0));
        vec3 rc = GFX_PRIMARY * (0.35 + 0.25 * hash12(id + 4.0)) * lit * (1.0 - crater * 0.35);
        rc += GFX_ACCENT * pow(max(dot(n2, L), 0.0), 3.0) * 0.15;
        col = mix(col, rc * (1.0 - fi * 0.2), smoothstep(0.0, -0.01, d));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
