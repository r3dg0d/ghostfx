// @id deep-ocean
// @name Deep Ocean
// @category ocean
// @description The view from far below the surface: shafts of light fading into the abyss and drifting marine snow.
// @tags ocean, underwater, dark, light-rays, calm
// @mode background
// @uses value particles
// @color PRIMARY #0A4A6E
// @color SECONDARY #01070F
// @color ACCENT #7FD3E8
// @param RAYS float 1.0 0.0 2.0 God-ray strength
// @param SNOW float 1.0 0.0 2.0 Marine snow density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Depth gradient: lighter toward the surface.
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, smoothstep(-0.6, 0.7, p.y));

    // Light shafts fanning down from a point above the screen.
    vec2 src = vec2(0.15 * sin(t * 0.05), 1.3);
    vec2 d = p - src;
    float a = atan(d.x, -d.y);
    float rays = vnoise(vec2(a * 18.0, t * 0.25)) * vnoise(vec2(a * 41.0 + 3.0, -t * 0.18));
    rays = pow(rays, 1.5) * smoothstep(-0.5, 0.6, p.y);
    col += GFX_ACCENT * rays * 0.55 * P_RAYS;

    // Surface shimmer near the top edge.
    float shim = vnoise(vec2(p.x * 9.0 + t * 0.4, p.y * 3.0)) * vnoise(vec2(p.x * 17.0 - t * 0.3, 2.0));
    col += GFX_ACCENT * shim * smoothstep(0.25, 0.5, p.y) * 0.35;

    // Marine snow: slow, sinking specks on three depth layers.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float sc = 18.0 + fi * 14.0;
        vec2 q = p * sc + vec2(sin(t * 0.2 + fi) * 0.6, t * (0.25 + 0.15 * fi));
        vec2 c = particle_cell(q, 0.12, 0.7);
        col += GFX_ACCENT * c.x * step(1.0 - 0.35 * P_SNOW, c.y) * (0.5 - 0.12 * fi);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
