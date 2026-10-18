// @id bioluminescent-ocean
// @name Bioluminescent Ocean
// @category ocean
// @description Night surf where every breaking wave stirs up glowing blue plankton that sparkle and fade in its wake.
// @tags ocean, glow, plankton, night, blue, magical
// @mode background
// @uses fbm particles
// @color PRIMARY #00E5FF
// @color SECONDARY #020B14
// @color ACCENT #4D7CFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Waves roll diagonally across the screen; crest = recently disturbed water.
    float wave = p.y * 2.5 + p.x * 0.6 + 0.3 * fbm(p * 2.0 + t * 0.1);
    float ph = fract(wave * 1.1 - t * 0.18);
    float crest = exp(-ph * 9.0) * smoothstep(0.0, 0.02, ph);
    float wake = exp(-ph * 2.5);

    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.04 * fbm(p * 3.0 - t * 0.05);
    col += GFX_PRIMARY * crest * 0.55 * (0.5 + fbm(p * 8.0 + vec2(t, 0.0)));

    // Plankton sparks: brightest just behind the crest, fading after.
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        vec2 c = particle_cell(p * (50.0 + fi * 30.0) + fi * 3.0, 0.18, 0.8);
        float flick = 0.6 + 0.4 * sin(t * 5.0 + c.y * 60.0);
        col += mix(GFX_PRIMARY, GFX_ACCENT, c.y) * c.x * flick * (wake * 1.5 + 0.05) * step(0.55, c.y);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
