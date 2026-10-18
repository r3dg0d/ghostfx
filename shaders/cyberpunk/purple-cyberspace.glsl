// @id purple-cyberspace
// @name Purple Cyberspace
// @category cyberpunk
// @description Drifting through a violet data dimension: grid floor and ceiling, purple fog, and wireframe data cubes slowly spinning.
// @tags cyberspace, purple, grid, wireframe, immersive
// @mode background
// @uses hash sdf
// @color PRIMARY #A24BFF
// @color SECONDARY #07020F
// @color ACCENT #FF6BE8

float wire_cube(vec2 p, float s, float a) {
    // 2D projection of a rotating cube: two offset squares and joining lines.
    vec2 o = vec2(cos(a), sin(a * 0.7)) * s * 0.4;
    float d = abs(sd_box(p - o, vec2(s))) ;
    d = min(d, abs(sd_box(p + o, vec2(s))));
    d = min(d, sd_segment(p, vec2(-s, -s) - o, vec2(-s, -s) + o));
    d = min(d, sd_segment(p, vec2(s, -s) - o, vec2(s, -s) + o));
    d = min(d, sd_segment(p, vec2(-s, s) - o, vec2(-s, s) + o));
    d = min(d, sd_segment(p, vec2(s, s) - o, vec2(s, s) + o));
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Floor and ceiling planes.
    float ay = abs(p.y) + 1e-3;
    float z = 0.12 / ay;
    vec2 g = vec2(p.x * z, z + t * 0.1) * 14.0;
    float line = grid_lines(g, 1.2 * gfx_dpi());
    float fog = exp(-z * 0.8);
    col += GFX_PRIMARY * line * fog * 0.7 * smoothstep(0.03, 0.15, ay);
    col += GFX_PRIMARY * 0.12 * exp(-ay * 6.0);
    // Floating data cubes at several depths.
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float depth = 0.6 + 0.4 * hash11(fi);
        vec2 c = vec2((hash11(fi * 3.1) - 0.5) * gfx_aspect() * 0.9, (hash11(fi * 7.3) - 0.5) * 0.4);
        c.y += 0.02 * sin(t * 0.5 + fi);
        float s = 0.03 + 0.04 * depth;
        float d = wire_cube(p - c, s, t * (0.3 + 0.2 * fi) + fi);
        col += mix(GFX_PRIMARY, GFX_ACCENT, hash11(fi + 2.0)) * (smoothstep(0.002, 0.0, d) + exp(-d * 80.0) * 0.2) * depth;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
