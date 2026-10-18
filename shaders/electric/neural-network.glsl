// @id neural-network
// @name Neural Network
// @category electric
// @description Layers of neurons wired together, with activation pulses firing forward from input to output in waves.
// @tags neural, network, ai, nodes, pulses, blue
// @mode background
// @uses hash sdf
// @color PRIMARY #6BA8FF
// @color SECONDARY #04050B
// @color ACCENT #FF7AD9
// @param LAYERS int 5 3 7 Number of layers

vec2 neuron(int l, int i, int n) {
    float x = (float(l) / float(P_LAYERS - 1) - 0.5) * 0.9 + 0.35;
    float y = (float(i) + 0.5) / float(n) - 0.5;
    return vec2(x * gfx_aspect() * 0.55 + 0.1, y * 0.8);
}

int layer_size(int l) { return l == 0 || l == P_LAYERS - 1 ? 4 : 6; }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    float wave = fract(t * 0.25) * float(P_LAYERS);
    for (int l = 0; l < P_LAYERS - 1; l++) {
        int na = layer_size(l), nb = layer_size(l + 1);
        for (int i = 0; i < 6; i++) {
            if (i >= na) break;
            vec2 a = neuron(l, i, na);
            for (int j = 0; j < 6; j++) {
                if (j >= nb) break;
                vec2 b = neuron(l + 1, j, nb);
                float w = hash12(vec2(float(l * 37 + i), float(j)));
                float d = sd_segment(p, a, b);
                col += GFX_PRIMARY * smoothstep(0.0025, 0.0, d) * (0.05 + 0.1 * w);
                // Pulse travelling along the edge while the wave crosses it.
                float k = clamp(wave - float(l), 0.0, 1.0);
                vec2 pk = mix(a, b, k);
                float firing = step(0.5, w) * step(0.001, k) * step(k, 0.999);
                col += mix(GFX_PRIMARY, GFX_ACCENT, w) * firing * exp(-length(p - pk) * 180.0) * 0.8;
            }
        }
    }
    for (int l = 0; l < P_LAYERS; l++) {
        int n = layer_size(l);
        float fire = exp(-pow((wave - float(l)) * 2.0, 2.0));
        for (int i = 0; i < 6; i++) {
            if (i >= n) break;
            float d = length(p - neuron(l, i, n));
            col += mix(GFX_PRIMARY, GFX_ACCENT, fire) * (smoothstep(0.014, 0.01, d) * (0.4 + 0.6 * fire) + exp(-d * 40.0) * 0.15 * fire);
        }
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
