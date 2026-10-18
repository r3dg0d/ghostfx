// @id power-grid
// @name Power Grid
// @category electric
// @description A network of substations and transmission lines, with packets of energy hopping from node to node.
// @tags grid, network, energy, nodes, yellow
// @mode background
// @uses hash sdf
// @color PRIMARY #FFD24D
// @color SECONDARY #050608
// @color ACCENT #4DA3FF
// @param SCALE float 7.0 3.0 16.0 Nodes per screen height

vec2 node(vec2 cell) { return cell + 0.5 + (hash22(cell) - 0.5) * 0.6; }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_SCALE;
    vec2 cell = floor(g);
    vec3 col = GFX_SECONDARY;
    // Each node links to its right and upper neighbours; check the 3x3 block.
    for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++) {
        vec2 c = cell + vec2(float(i), float(j));
        vec2 a = node(c);
        for (int k = 0; k < 2; k++) {
            vec2 nb = c + (k == 0 ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
            if (hash12(c + nb * 0.7) < 0.3) continue;
            vec2 b = node(nb);
            float d = sd_segment(g, a, b);
            col += GFX_ACCENT * smoothstep(0.03, 0.0, d) * 0.25;
            // Energy packet travelling along the line.
            float sp = fract(t * (0.3 + hash12(c + float(k))) + hash12(nb));
            vec2 pk = mix(a, b, sp);
            col += GFX_PRIMARY * (exp(-length(g - pk) * 14.0) * 0.6 + smoothstep(0.06, 0.0, length(g - pk)));
        }
        float nd = length(g - a);
        col += GFX_PRIMARY * (smoothstep(0.08, 0.05, nd) * 0.8 + exp(-nd * 10.0) * 0.25) * (0.6 + 0.4 * sin(t * 2.0 + hash12(c) * 20.0));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
