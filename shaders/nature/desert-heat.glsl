// @id desert-heat
// @name Desert Heat
// @category nature
// @description Sun-bleached dunes under a white-hot sky, with a shimmering mirage pooling on the horizon and wobbling the air.
// @tags desert, dunes, heat, mirage, warm, distortion
// @mode background
// @uses value gradient
// @distorts true
// @color PRIMARY #E8B26A
// @color SECONDARY #8A5A2E
// @color ACCENT #F7E7C6

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = 0.02;
    // Heat shimmer near the horizon.
    vec2 shim = vec2(gnoise(vec2(p.x * 30.0, p.y * 40.0 - t * 3.0)), 0.0) * exp(-abs(p.y - hy) * 15.0);
    vec2 q = p + shim * 0.006;
    vec3 sky = mix(GFX_ACCENT, vec3(0.55, 0.7, 0.85), smoothstep(hy, 0.5, q.y));
    vec3 col = sky;
    if (q.y < hy + 0.02) {
        // Mirage: the sky reflected in a hot layer just above the ground.
        float mir = smoothstep(hy + 0.02, hy - 0.02, q.y) * exp(-(hy - q.y) * 25.0);
        col = mix(col, mix(GFX_ACCENT, vec3(0.6, 0.75, 0.9), 0.4), mir);
    }
    // Dunes: three ridged sine layers with soft shading.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float x = q.x * (1.0 + fi * 0.7) + fi * 2.0 + t * 0.003;
        float h = hy - 0.02 - fi * 0.12 + 0.05 * (1.0 - abs(sin(x * 2.0 + vnoise(vec2(x, fi)) * 1.5))) + 0.02 * sin(x * 7.0);
        float slope = cos(x * 2.0);
        vec3 dc = mix(GFX_SECONDARY, GFX_PRIMARY, 0.55 + 0.45 * slope) * (1.0 - fi * 0.08 * -1.0);
        col = mix(col, dc, smoothstep(0.003, 0.0, q.y - h));
    }
    vec4 term = gfx_term(uv + gfx_text_offset(shim * 2.0 * gfx_dpi() / iResolution.xy * 3.0));
    fragColor = gfx_compose(uv, term, col);
}
