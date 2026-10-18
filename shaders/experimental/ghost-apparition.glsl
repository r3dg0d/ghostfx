// @id ghost-apparition
// @name Ghost Apparition
// @category experimental
// @description A translucent spectre with hollow eyes drifts slowly across the fog, fading in and out of sight.
// @tags ghost, spectre, horror, fog, eerie, halloween
// @mode background
// @uses fbm sdf
// @color PRIMARY #CFE8FF
// @color SECONDARY #04070A
// @color ACCENT #6FA0C0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.12 * fbm(p * 2.0 + vec2(t * 0.03, 0.0));
    // Path across the screen with a gentle bob.
    float cyc = mod(t * 0.04, 1.0);
    vec2 c = vec2((cyc * 2.0 - 1.0) * (0.5 * gfx_aspect() + 0.3), 0.05 + 0.04 * sin(t * 0.7));
    vec2 q = (p - c) / 0.22;
    // Body: rounded head on a tapering, rippling tail.
    float wave = 0.08 * sin(q.y * 6.0 + t * 2.0);
    float head = length(q - vec2(0.0, 0.35)) - 0.38;
    float tail = sd_box(q - vec2(wave, -0.25), vec2(0.38 * smoothstep(-1.0, 0.3, q.y), 0.6));
    float d = smin(head, tail, 0.15);
    // Ragged hem.
    d = max(d, -(q.y + 0.75 + 0.08 * sin(q.x * 18.0 + t * 3.0)));
    float body = smoothstep(0.08, -0.15, d);
    float eyes = smoothstep(0.1, 0.06, length((q - vec2(0.0, 0.4)) * vec2(1.0, 0.8) - vec2(sign(q.x) * 0.14, 0.0)));
    float mouth = smoothstep(0.07, 0.04, length((q - vec2(0.0, 0.18)) * vec2(1.4, 1.0)));
    float wisp = fbm(q * 2.0 + t * 0.3);
    float vis = (0.4 + 0.6 * smoothstep(0.2, 0.8, 0.5 + 0.5 * sin(t * 0.5))) * smoothstep(0.0, 0.1, cyc) * smoothstep(1.0, 0.9, cyc);
    vec3 g = GFX_PRIMARY * body * (0.5 + 0.4 * wisp) * (1.0 - eyes - mouth);
    col += g * vis + GFX_ACCENT * exp(-max(d, 0.0) * 6.0) * 0.12 * vis;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
