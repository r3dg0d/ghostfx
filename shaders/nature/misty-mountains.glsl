// @id misty-mountains
// @name Misty Mountains
// @category nature
// @description Ridge after ridge of mountains fade into blue haze, with bands of mist drifting slowly between them.
// @tags mountains, mist, landscape, calm, blue, layers
// @mode background
// @uses fbm
// @color PRIMARY #A9C1D9
// @color SECONDARY #0F1A26
// @color ACCENT #2B4359
// @param RIDGES int 5 2 8 Number of ridge layers

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_PRIMARY * 0.8, GFX_SECONDARY * 1.5, smoothstep(-0.1, 0.5, p.y));
    for (int i = 0; i < P_RIDGES; i++) {
        float fi = float(i);
        float k = fi / float(P_RIDGES - 1);         // 0 = far, 1 = near
        float x = p.x * (1.0 + k * 1.5) + fi * 3.1 + t * 0.004 * (k + 0.2);
        float h = 0.2 - k * 0.55 + 0.18 * ridged(vec2(x * 0.9, fi * 2.0)) * (1.0 - k * 0.3);
        vec3 rc = mix(GFX_PRIMARY * 0.65, GFX_SECONDARY, k);   // atmospheric perspective
        col = mix(col, rc, smoothstep(0.003, 0.0, p.y - h));
        // Mist band in the valley in front of this ridge.
        float mist = fbm(vec2(p.x * 2.0 + t * 0.02 * (1.0 + fi * 0.3), fi * 5.0));
        float band = exp(-pow((p.y - h + 0.05) * 12.0, 2.0)) * smoothstep(0.3, 0.7, mist);
        col = mix(col, GFX_PRIMARY * 0.8, band * 0.45 * (1.0 - k * 0.5));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
