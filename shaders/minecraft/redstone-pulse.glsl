// @id redstone-pulse
// @name Redstone Pulse
// @category minecraft
// @description Glowing red wiring snakes across a stone floor, with signal pulses racing outward from powered sources.
// @tags redstone, circuit, red, pixel, pulse, minecraft-inspired
// @mode background
// @uses hash
// @inspired Minecraft redstone dust (original procedural interpretation, no game assets)
// @color PRIMARY #FF1A1A
// @color SECONDARY #1A1A1D
// @color ACCENT #FFB3A3
// @param GRID float 18.0 8.0 40.0 Blocks across the screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_GRID;
    vec2 id = floor(g);
    vec2 f = fract(g) - 0.5;

    // Stone texture: 16x16 pixel noise per block.
    float tex = hash12(floor(fract(g) * 16.0) + id * 17.0);
    vec3 col = GFX_SECONDARY * (0.8 + 0.4 * tex);

    // Wire topology: each cell connects right and/or up based on a hash; the
    // neighbour's choice decides left/down so wires always join.
    float wire = step(0.45, hash12(id));
    float right = wire * step(0.5, hash12(id + vec2(0.3, 0.0))) * step(0.45, hash12(id + vec2(1.0, 0.0)));
    float up = wire * step(0.5, hash12(id + vec2(0.0, 0.3))) * step(0.45, hash12(id + vec2(0.0, 1.0)));
    float left = step(0.45, hash12(id - vec2(1.0, 0.0))) * step(0.5, hash12(id - vec2(1.0, 0.0) + vec2(0.3, 0.0))) * wire;
    float down = step(0.45, hash12(id - vec2(0.0, 1.0))) * step(0.5, hash12(id - vec2(0.0, 1.0) + vec2(0.0, 0.3))) * wire;
    float w = 0.09;
    float m = wire * step(max(abs(f.x), abs(f.y)), 0.16);
    m = max(m, right * step(abs(f.y), w) * step(0.0, f.x));
    m = max(m, left * step(abs(f.y), w) * step(f.x, 0.0));
    m = max(m, up * step(abs(f.x), w) * step(0.0, f.y));
    m = max(m, down * step(abs(f.x), w) * step(f.y, 0.0));

    // Power: pulses spread from moving sources in Manhattan distance.
    float power = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 src = floor((hash22(vec2(fi, floor(t / 6.0 + fi * 0.3))) - 0.5) * vec2(gfx_aspect(), 1.0) * P_GRID);
        float d = abs(id.x - src.x) + abs(id.y - src.y);
        power = max(power, exp(-pow(d - mod(t + fi * 2.0, 6.0) * 5.0, 2.0) * 0.08) * smoothstep(15.0, 0.0, d));
    }
    vec3 wirec = mix(GFX_PRIMARY * 0.3, GFX_PRIMARY, 0.25 + 0.75 * power);
    wirec += GFX_ACCENT * step(0.82, hash12(floor(fract(g) * 16.0) + id)) * power;
    col = mix(col, wirec, m);
    col += GFX_PRIMARY * power * wire * 0.12;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
