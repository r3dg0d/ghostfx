// @id snowfall
// @name Snowfall
// @category particles
// @description Quiet snow falling in layers through a blue winter night, near flakes large and soft, far ones fine and slow.
// @tags snow, winter, particles, calm, cold
// @mode background
// @uses hash
// @color PRIMARY #FFFFFF
// @color SECONDARY #0B1626
// @color ACCENT #2A4466
// @param WIND float 0.3 -1.5 1.5 Horizontal wind
// @param DENSITY float 1.0 0.3 2.0 Flake density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT, smoothstep(0.6, -0.6, p.y));

    for (int i = 0; i < GFX_LAYERS + 1; i++) {
        float fi = float(i);
        float depth = 1.0 + fi * 0.7;
        float sc = 6.0 * depth;
        vec2 q = p * sc;
        q += vec2(t * P_WIND / depth, t * 1.4 / sqrt(depth)) * 1.6;
        q += fi * 31.7;
        vec2 id = floor(q);
        if (hash12(id) > 0.45 * P_DENSITY) continue;
        vec2 f = fract(q) - 0.5;
        f.x += 0.3 * sin(t * 1.3 + hash12(id + 2.0) * 20.0);
        f += (hash22(id + 5.0) - 0.5) * 0.4;
        float r = 0.09 + 0.06 * hash12(id + 7.0);
        float flake = smoothstep(r, r * (0.2 + 0.1 * fi), length(f));
        col += GFX_PRIMARY * flake * (0.95 / depth);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
