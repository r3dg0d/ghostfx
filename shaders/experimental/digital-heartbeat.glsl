// @id digital-heartbeat
// @name Digital Heartbeat
// @category experimental
// @description A glowing ECG trace sweeps across the bottom of the screen, its heartbeat pulse echoed by a soft red glow.
// @tags ecg, heartbeat, medical, monitor, pulse, red
// @mode background
// @uses sdf
// @color PRIMARY #3DFF8A
// @color SECONDARY #030705
// @color ACCENT #FF3D5A
// @param BPM float 64.0 40.0 140.0 Heart rate

// One PQRST complex for phase x in [0,1).
float ecg(float x) {
    float y = 0.0;
    y += 0.08 * exp(-pow((x - 0.18) * 30.0, 2.0));            // P
    y -= 0.08 * exp(-pow((x - 0.30) * 90.0, 2.0));            // Q
    y += 0.9 * exp(-pow((x - 0.33) * 70.0, 2.0));             // R
    y -= 0.18 * exp(-pow((x - 0.36) * 70.0, 2.0));            // S
    y += 0.18 * exp(-pow((x - 0.6) * 14.0, 2.0));             // T
    return y;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float beat = P_BPM / 60.0;
    vec3 col = GFX_SECONDARY;
    float x = uv.x * 3.0;                 // three beats across the screen
    float head = fract(t * beat / 3.0) * 3.0;
    float behind = mod(head - x, 3.0);
    float y = -0.36 + ecg(fract(x)) * 0.12;
    float d = abs(p.y - y);
    float trace = smoothstep(0.004, 0.0, d) + exp(-d * 90.0) * 0.25;
    float fade = exp(-behind * 1.2) * step(0.02, behind) + smoothstep(0.02, 0.0, behind);
    col += GFX_PRIMARY * trace * fade;
    // Grid and pulse glow.
    col += GFX_PRIMARY * 0.04 * grid_lines(p * 20.0, 1.0) * smoothstep(-0.15, -0.3, p.y);
    float pulse = exp(-fract(t * beat) * 6.0);
    col += GFX_ACCENT * pulse * 0.08 * exp(-length(p - vec2(0.55, 0.3)) * 3.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
