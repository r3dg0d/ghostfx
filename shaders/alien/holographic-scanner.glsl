// @id holographic-scanner
// @name Holographic Scanner
// @category alien
// @description A cyan scan beam sweeps the screen, briefly revealing a measurement grid and lighting up the text as it passes.
// @tags scanner, hologram, cyan, sci-fi, beam
// @mode glow
// @uses hash
// @color PRIMARY #26E7FF
// @color SECONDARY #020810
// @color ACCENT #CFFBFF
// @param PERIOD float 6.0 2.0 20.0 Seconds per sweep

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float ph = fract(t / P_PERIOD);
    // Ping-pong sweep, eased at the turnarounds.
    float y = 1.0 - abs(ph * 2.0 - 1.0);
    y = y * y * (3.0 - 2.0 * y);
    float d = uv.y - y;
    float beam = exp(-abs(d) * iResolution.y / (4.0 * gfx_dpi()));
    float wake = exp(-abs(d) * 8.0);

    vec3 fx = GFX_SECONDARY;
    vec2 g = abs(fract(p * 16.0) - 0.5);
    float grid = smoothstep(0.47, 0.5, max(g.x, g.y));
    fx += GFX_PRIMARY * grid * (0.04 + 0.4 * wake);
    // Measurement ticks along the beam.
    float tick = step(0.9, fract(uv.x * 40.0)) * exp(-abs(d) * 200.0);
    fx += GFX_ACCENT * tick * 0.8;
    vec3 light = GFX_PRIMARY * beam * 0.6 + GFX_PRIMARY * wake * 0.08;
    fragColor = gfx_compose_glow(uv, gfx_term(uv), fx, light);
}
