// @id circuit-growth
// @name Circuit Growth
// @category electric
// @description Copper traces grow outward from a seed chip like roots, branching at right angles until the board is wired, then fade and regrow.
// @tags circuit, growth, traces, copper, animated
// @mode background
// @uses hash
// @color PRIMARY #FFB45C
// @color SECONDARY #050806
// @color ACCENT #5CFFD2
// @param CYCLE float 18.0 6.0 60.0 Seconds per growth cycle

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    vec2 seed = vec2(0.45, -0.05);
    vec2 g = (p - seed) * 26.0;
    vec2 id = floor(g);
    vec2 f = fract(g) - 0.5;
    // Growth distance: Manhattan distance from the seed, perturbed per cell.
    float dist = abs(id.x) + abs(id.y) + hash12(id) * 3.0;
    float grown = smoothstep(dist - 1.0, dist, k * 40.0);
    // Each cell routes a trace toward the seed: horizontal if |x| dominant.
    bool horiz = abs(id.x) > abs(id.y) + hash12(id + 2.0) * 2.0 - 1.0;
    float trace = horiz ? step(abs(f.y), 0.08) : step(abs(f.x), 0.08);
    float present = step(0.25, hash12(id + 5.0));
    float pad = step(0.9, hash12(id + 7.0)) * smoothstep(0.22, 0.17, length(f));
    float tip = exp(-pow((k * 40.0 - dist), 2.0) * 0.5);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * (trace * present + pad) * grown * (0.35 + 0.6 * tip) * (1.0 - smoothstep(0.85, 1.0, k));
    col += GFX_ACCENT * trace * present * tip * 0.6;
    float chip = step(max(abs(p.x - seed.x), abs(p.y - seed.y)), 0.04);
    col = mix(col, vec3(0.08), chip);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
