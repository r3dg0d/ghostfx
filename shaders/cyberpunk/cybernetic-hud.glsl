// @id cybernetic-hud
// @name Cybernetic HUD
// @category cyberpunk
// @description An augmented-reality overlay: corner brackets, a scrolling compass tape, a slow reticle and live telemetry bars.
// @tags hud, cyberpunk, interface, augmented, cyan
// @mode background
// @uses sdf hash
// @color PRIMARY #28F0FF
// @color SECONDARY #03070B
// @color ACCENT #FF9A28

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float px = gfx_pxsize() * 1.5;
    vec3 col = GFX_SECONDARY;
    vec2 half_ = vec2(0.5 * gfx_aspect(), 0.5) - 0.03;
    // Corner brackets.
    vec2 a = abs(p) - half_;
    float br = (step(-0.06, a.x) * smoothstep(px, 0.0, abs(a.y))) + (step(-0.06, a.y) * smoothstep(px, 0.0, abs(a.x)));
    col += GFX_PRIMARY * br * step(a.x, 0.001) * step(a.y, 0.001) * 0.8;
    // Compass tape across the top.
    // Compass tape across the bottom edge (kept away from the prompt line).
    if (abs(p.y + 0.455) < 0.015 && abs(p.x) < 0.45) {
        float heading = p.x * 60.0 + t * 4.0;
        float tick = smoothstep(0.42, 0.48, abs(fract(heading / 5.0) - 0.5));
        float major = smoothstep(0.47, 0.495, abs(fract(heading / 30.0) - 0.5));
        col += GFX_PRIMARY * (tick * 0.35 * step(p.y, -0.455) + major * 0.8);
    }
    col += GFX_ACCENT * smoothstep(0.004, 0.0, sd_triangle(p - vec2(0.0, -0.43), 0.008));
    // Reticle at the right third.
    vec2 c = p - vec2(0.45, -0.02);
    float r = length(c);
    float ring = smoothstep(px, 0.0, abs(r - 0.12)) * step(0.3, fract(atan(c.y, c.x) / 6.2831 * 8.0 + t * 0.05));
    ring += smoothstep(px, 0.0, abs(r - 0.15)) * step(0.85, fract(atan(c.y, c.x) / 6.2831 * 36.0)) ;
    float cross_ = (smoothstep(px, 0.0, abs(c.x)) + smoothstep(px, 0.0, abs(c.y))) * step(0.03, r) * step(r, 0.08);
    col += GFX_PRIMARY * (ring * 0.6 + cross_ * 0.6);
    // Telemetry bars along the bottom right.
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        vec2 b = p - vec2(0.5 * gfx_aspect() - 0.32 + fi * 0.045, -0.42);
        float level = 0.03 + 0.05 * (0.5 + 0.5 * sin(t * (1.0 + fi * 0.37) + fi));
        float bar = step(abs(b.x), 0.012) * step(0.0, b.y) * step(b.y, level);
        col += mix(GFX_PRIMARY, GFX_ACCENT, step(0.07, level)) * bar * 0.6;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
