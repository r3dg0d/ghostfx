// @id vaporwave-clouds
// @name Vaporwave Clouds
// @category cyberpunk
// @description Pastel pink-and-teal clouds drift across a lilac sky behind scanlines and a hazy setting sun. Pure aesthetic.
// @tags vaporwave, pastel, clouds, aesthetic, retro
// @mode background
// @uses fbm
// @color PRIMARY #FF9AD5
// @color SECONDARY #2A1F4A
// @color ACCENT #7FE7E0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_PRIMARY * 0.75, GFX_SECONDARY, smoothstep(-0.4, 0.5, p.y));
    vec2 s = p - vec2(0.3, -0.05);
    float sun = smoothstep(0.17, 0.165, length(s)) * step(0.5, fract(s.y * 30.0 + 0.5) + smoothstep(-0.05, 0.05, s.y));
    col = mix(col, mix(vec3(1.0, 0.85, 0.6), GFX_PRIMARY, smoothstep(0.1, -0.15, s.y)), sun * 0.85);
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = vec2(p.x * (1.5 + fi * 0.5) + t * (0.02 + 0.01 * fi), p.y * (3.0 + fi) + fi * 4.0);
        float cl = smoothstep(0.5, 0.75, fbm(q));
        vec3 cc = mix(GFX_ACCENT, GFX_PRIMARY, fi / 2.0) * (0.8 + 0.2 * fi);
        col = mix(col, cc, cl * (0.55 - fi * 0.1));
    }
    col *= 0.94 + 0.06 * step(0.5, fract(fragCoord.y / (3.0 * gfx_dpi())));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
