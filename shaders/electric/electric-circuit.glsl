// @id electric-circuit
// @name Electric Circuit
// @category electric
// @description A green circuit board with copper traces, gold pads and vias, as cyan signals pulse along the tracks.
// @tags pcb, circuit, electronics, green, signals
// @mode background
// @uses hash
// @color PRIMARY #33F0FF
// @color SECONDARY #062113
// @color ACCENT #C8913A
// @param SCALE float 20.0 8.0 50.0 Grid cells per screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_SCALE;
    vec2 id = floor(g);
    vec2 f = fract(g) - 0.5;
    float h = hash12(id);
    vec3 col = GFX_SECONDARY * (0.9 + 0.2 * hash12(floor(fragCoord / (3.0 * gfx_dpi()))));

    // Trace layout per cell: straight, 45-degree bend or empty.
    float w = 0.09;
    float trace = 0.0;
    float along = 0.0;
    if (h < 0.35) { trace = step(abs(f.y), w); along = f.x + id.x; }
    else if (h < 0.55) { trace = step(abs(f.x), w); along = f.y + id.y; }
    else if (h < 0.7) {
        // Diagonal jog between horizontal runs.
        trace = step(abs(f.x - f.y), w * 1.4);
        along = (f.x + f.y) * 0.7 + id.x;
    }
    float pad = step(0.88, hash12(id + 3.0));
    float padShape = smoothstep(0.24, 0.2, length(f));
    float via = step(0.93, hash12(id + 7.0)) * smoothstep(0.12, 0.09, length(f)) * step(0.05, length(f));
    col = mix(col, GFX_ACCENT * 0.75, trace);
    col = mix(col, GFX_ACCENT * 1.1, pad * padShape);
    col = mix(col, vec3(0.05), via);

    // Signals: bright dashes moving along traces, phase per row/column.
    float sig = pow(0.5 + 0.5 * sin(along * 1.3 - t * (3.0 + 2.0 * hash12(vec2(id.y, 0.0)))), 30.0);
    col += GFX_PRIMARY * sig * trace * 1.4;
    col += GFX_PRIMARY * sig * exp(-length(f) * 4.0) * 0.1 * trace;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
