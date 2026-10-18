// @id neon-pulse
// @name Neon Pulse
// @category cyberpunk
// @description A neon tube traces the edge of the window, breathing in brightness with the occasional sign-like flicker.
// @tags neon, border, pulse, frame, glow
// @mode background
// @uses sdf value
// @flashing true
// @color PRIMARY #FF2E8A
// @color SECONDARY #08040B
// @color ACCENT #7A2EFF
// @param INSET float 0.025 0.005 0.08 Distance of the tube from the edge
// @param BREATH float 4.0 1.0 12.0 Seconds per pulse

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 half_ = vec2(0.5 * gfx_aspect(), 0.5) - P_INSET;
    float d = abs(sd_box(p, half_ - 0.03) - 0.03);
    float breath = 0.65 + 0.35 * sin(t / P_BREATH * 6.2831);
    float flick = 1.0 - gfx_flash(0.6 * step(0.97, vnoise(vec2(t * 8.0, 0.0))));
    float b = breath * flick;
    // Colour shifts along the perimeter.
    float along = (p.x / gfx_aspect() + p.y) * 0.5 + 0.5;
    vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.2, 0.8, along));
    vec3 col = GFX_SECONDARY;
    col += c * (smoothstep(0.004, 0.0015, d) * 1.2 + exp(-d * 60.0) * 0.4 + exp(-d * 8.0) * 0.12) * b;
    col += vec3(1.0) * smoothstep(0.0015, 0.0, d) * b * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
