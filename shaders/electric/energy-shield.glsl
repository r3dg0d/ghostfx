// @id energy-shield
// @name Energy Shield
// @category electric
// @description A hexagonal force field hums across the window; impacts ripple out and light up the cells they cross.
// @tags shield, hexagon, sci-fi, energy, cyan
// @mode background
// @uses hash sdf
// @color PRIMARY #4DE1FF
// @color SECONDARY #020810
// @color ACCENT #FFB04D
// @param CELLS float 16.0 6.0 40.0 Hex cells per screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 h = p * P_CELLS;
    vec4 ht = hex_tile(h);
    vec2 g = ht.xy;
    vec2 cid = ht.zw;
    float edge = smoothstep(0.06, 0.0, 0.5 - hex_edge(g));

    float hum = 0.5 + 0.5 * sin(t * 1.5 + cid.y * 0.3);
    float ripple = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float cyc = floor(t / 3.0 + fi / 3.0);
        float age = fract(t / 3.0 + fi / 3.0) * 3.0;
        vec2 c = (hash22(vec2(fi, cyc)) - 0.5) * vec2(gfx_aspect(), 1.0) * 0.9;
        float d = length(cid / P_CELLS - c);
        ripple += exp(-pow((d - age * 0.3) * 14.0, 2.0)) * exp(-age * 0.9);
        ripple += exp(-d * 20.0) * exp(-age * 4.0) * 2.0;
    }
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * edge * (0.12 + 0.08 * hum);
    col += mix(GFX_PRIMARY, GFX_ACCENT, clamp(ripple - 0.5, 0.0, 1.0)) * ripple * (0.25 + edge * 0.8);
    // Fresnel-like brightening toward the window edge.
    float fr = pow(length(p / vec2(0.5 * gfx_aspect(), 0.5)) / 1.42, 3.0);
    col += GFX_PRIMARY * fr * 0.25;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
