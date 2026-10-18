// @id lava-lamp
// @name Lava Lamp
// @category liquid
// @description Slow blobs of glowing wax rise, stretch, merge and sink through warm liquid, just like the 70s classic.
// @tags lava-lamp, retro, blobs, warm, calm, 70s
// @mode background
// @uses sdf hash
// @color PRIMARY #FF4D2E
// @color SECONDARY #2A0815
// @color ACCENT #FFC23D
// @param BLOBS int 7 3 12 Number of wax blobs

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time() * 0.35;
    float d = 1e3;
    for (int i = 0; i < P_BLOBS; i++) {
        float fi = float(i);
        float h = hash11(fi * 3.7);
        // Heat cycle: each blob rises and falls on its own slow period.
        float y = sin(t * (0.3 + 0.25 * h) + fi * 1.7) * 0.42;
        float x = (h - 0.5) * gfx_aspect() * 0.8 + 0.05 * sin(t * 0.7 + fi);
        float r = 0.06 + 0.06 * hash11(fi + 5.0);
        // Rising blobs stretch vertically.
        vec2 q = (p - vec2(x, y)) * vec2(1.0, 0.75 + 0.25 * cos(t * (0.3 + 0.25 * h) + fi * 1.7));
        d = smin(d, length(q) - r, 0.12);
    }
    // Pools of wax at the top and bottom.
    d = smin(d, p.y + 0.46, 0.15);
    d = smin(d, 0.47 - p.y, 0.1);
    vec3 liquid = mix(GFX_SECONDARY, GFX_SECONDARY * 1.8, smoothstep(-0.5, 0.5, p.y));
    float wax = smoothstep(0.01, -0.01, d);
    float core = smoothstep(0.0, -0.08, d);
    vec3 wc = mix(GFX_PRIMARY, GFX_ACCENT, core * 0.7);
    vec3 col = mix(liquid, wc, wax);
    col += GFX_PRIMARY * 0.2 * exp(-max(d, 0.0) * 18.0) * (1.0 - wax);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
