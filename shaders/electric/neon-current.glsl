// @id neon-current
// @name Neon Current
// @category electric
// @description Smooth neon tubes snake across the screen while bright pulses of current flow along them.
// @tags neon, current, tubes, flow, pink, cyan
// @mode background
// @uses hash
// @color PRIMARY #FF3DA8
// @color SECONDARY #07040C
// @color ACCENT #3DF0FF
// @param TUBES int 4 1 8 Number of neon tubes

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < P_TUBES; i++) {
        float fi = float(i);
        float y0 = (fi + 0.5) / float(P_TUBES) - 0.5;
        float f1 = 1.5 + hash11(fi) * 2.0, f2 = 3.0 + hash11(fi + 3.0) * 3.0;
        float y = y0 + 0.08 * sin(p.x * f1 + fi + t * 0.2) + 0.03 * sin(p.x * f2 - t * 0.3);
        float dy = 0.08 * f1 * cos(p.x * f1 + fi + t * 0.2) + 0.03 * f2 * cos(p.x * f2 - t * 0.3);
        float d = abs(p.y - y) / sqrt(1.0 + dy * dy);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, step(0.5, hash11(fi + 9.0)));
        float tube = smoothstep(0.004, 0.0015, d);
        float halo = exp(-d * 60.0) * 0.35 + exp(-d * 12.0) * 0.08;
        // Pulses: travelling dashes of extra brightness.
        float pulse = pow(0.5 + 0.5 * sin(p.x * 6.0 - t * (2.0 + fi * 0.5) + fi * 2.0), 20.0);
        col += c * (tube * (0.7 + 0.8 * pulse) + halo * (0.7 + pulse));
        col += vec3(1.0) * tube * pulse * 0.5;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
