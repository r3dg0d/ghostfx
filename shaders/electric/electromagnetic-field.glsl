// @id electromagnetic-field
// @name Electromagnetic Field
// @category electric
// @description Field lines and equipotential contours flow around drifting positive and negative charges.
// @tags physics, field, electromagnetic, science, lines
// @mode background
// @uses hash
// @color PRIMARY #FF5A5A
// @color SECONDARY #03050A
// @color ACCENT #4D9DFF
// @param LINES float 10.0 4.0 24.0 Field lines per unit charge

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float psi = 0.0, phi = 0.0;
    // Four unit charges (+,+,-,-): integer charges and line counts keep
    // fract(psi) continuous across every atan() branch cut.
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float q = i < 2 ? 1.0 : -1.0;
        vec2 c = vec2(sin(t * (0.11 + 0.03 * fi) + fi * 1.7) * 0.6 * gfx_aspect() * 0.5, cos(t * (0.09 + 0.02 * fi) + fi * 2.9) * 0.3);
        vec2 d = p - c;
        psi += q * atan(d.y, d.x);
        phi += q / max(length(d), 0.01);
    }
    float N = floor(P_LINES);
    float fl = abs(fract(psi / 6.2831 * N) - 0.5);
    float lines = smoothstep(0.06, 0.0, 0.5 - fl);
    float eq = abs(fract(phi * 0.25) - 0.5);
    float equip = smoothstep(0.05, 0.0, 0.5 - eq);
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(-6.0, 6.0, phi)) * lines * 0.45;
    col += mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(-6.0, 6.0, phi)) * equip * 0.15;
    col += mix(GFX_ACCENT, GFX_PRIMARY, step(0.0, phi)) * smoothstep(8.0, 30.0, abs(phi)) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
