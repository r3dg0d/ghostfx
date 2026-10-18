// @id glass-ripples
// @name Glass Ripples
// @category glass
// @description Reeded, fluted glass: vertical ribs slice and refract soft colours drifting behind them.
// @tags glass, fluted, reeded, refraction, modern
// @mode background
// @uses value
// @distorts true
// @color PRIMARY #FF8A5C
// @color SECONDARY #0E1016
// @color ACCENT #5CC8FF
// @param FLUTES float 60.0 20.0 160.0 Flutes across the screen
// @param REFRACT float 1.0 0.0 3.0 Refraction strength

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float fx_ = fract(uv.x * P_FLUTES) - 0.5;
    // Each flute is a cylinder: refraction proportional to the surface slope.
    float slope = fx_ * 2.0;
    float off = slope * 0.06 * P_REFRACT;
    vec2 q = p + vec2(off * gfx_aspect(), 0.0);
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * 0.1 + fi * 2.1) * 0.7, cos(t * 0.08 + fi * 1.3) * 0.3);
        vec3 bc = i == 0 ? GFX_PRIMARY : i == 1 ? GFX_ACCENT : mix(GFX_PRIMARY, GFX_ACCENT, 0.5);
        col += bc * 0.5 * exp(-dot(q - c, q - c) * 6.0);
    }
    // Rib shading: bright highlight on one side, dark seam between flutes.
    col *= 0.85 + 0.25 * (0.5 - fx_);
    col += vec3(0.08) * pow(max(-slope, 0.0), 4.0);
    col *= smoothstep(0.5, 0.42, abs(fx_)) * 0.25 + 0.75;
    vec2 toff = vec2(slope * 1.2 * gfx_dpi() / iResolution.x, 0.0);
    fragColor = gfx_compose(uv, gfx_term(uv + gfx_text_offset(toff)), col);
}
