// @id neon-aurora
// @name Neon Aurora
// @category nature
// @description A synthwave aurora: hot pink and electric cyan curtains ripple over a dark violet sky above a glowing horizon line.
// @tags aurora, neon, synthwave, pink, cyan, sky
// @mode background
// @uses fbm hash
// @color PRIMARY #FF3DB4
// @color SECONDARY #0A0418
// @color ACCENT #3DF2FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    vec2 sg = p * 70.0;
    col += vec3(0.8) * step(0.99, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5));
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        float base = -0.15 + fi * 0.12 + 0.07 * sin(p.x * (2.0 + fi) + t * (0.2 + 0.1 * fi));
        float h = p.y - base;
        float rays = fbm(vec2(p.x * (16.0 + fi * 8.0) + t * 0.3, t * 0.1 + fi));
        float cur = smoothstep(-0.01, 0.02, h) * exp(-max(h, 0.0) * 4.5) * pow(rays, 2.0);
        col += (i == 0 ? GFX_PRIMARY : GFX_ACCENT) * cur * 1.4;
    }
    col += GFX_PRIMARY * smoothstep(0.004, 0.0, abs(p.y + 0.38)) * 0.8 + GFX_PRIMARY * 0.15 * exp(-abs(p.y + 0.38) * 12.0);
    col = mix(col, GFX_SECONDARY * 0.5, step(p.y, -0.38));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
