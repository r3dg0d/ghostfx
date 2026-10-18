// @id purple-fire
// @name Purple Fire
// @category fire
// @description A line of violet torches burning across the bottom of the screen, their flames swaying and lighting the dark above.
// @tags fire, purple, violet, torches, magic
// @mode background
// @uses fbm hash
// @color PRIMARY #3B0A6B
// @color SECONDARY #B24BFF
// @color ACCENT #FFE0FF
// @param TORCHES int 5 2 9 Number of torches
// @param HEIGHT float 0.5 0.2 0.9 Flame height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float y = p.y + 0.5;
    vec3 col = vec3(0.02, 0.0, 0.04) + GFX_PRIMARY * 0.15 * (1.0 - y);

    float span = gfx_aspect();
    for (int i = 0; i < P_TORCHES; i++) {
        float fi = float(i);
        float cx = (fi + 0.5) / float(P_TORCHES) * span - span * 0.5;
        float h = hash11(fi + 1.7);
        float H = P_HEIGHT * (0.8 + 0.4 * h);
        float sway = 0.05 * sin(t * 1.3 + fi * 2.0) * y / H;
        float lx = p.x - cx - sway;
        float n = fbm(vec2(lx * 6.0 + fi * 10.0, y * 4.0 - t * 2.5));
        float width = 0.07 * (1.0 + h) * pow(max(1.0 - y / H, 0.0), 0.6);
        float flame = clamp(1.0 - abs(lx) / max(width, 1e-4) + (n - 0.5) * 1.6, 0.0, 1.0) * step(0.0, y);
        flame *= smoothstep(H, H * 0.3, y + (n - 0.5) * 0.2);
        col += mix(GFX_PRIMARY, GFX_SECONDARY, flame) * flame * 1.2;
        col += GFX_ACCENT * pow(flame, 3.0) * 0.8;
        col += GFX_SECONDARY * 0.06 / (1.0 + 40.0 * dot(vec2(lx, y - 0.1), vec2(lx, y - 0.1)));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
