// @id spectral-rainbow
// @name Spectral Rainbow
// @category experimental
// @description Soft bands of pure spectral colour flow diagonally across the screen like light split by a prism, dim enough to work behind code.
// @tags rainbow, spectrum, colorful, soft, gradient
// @mode background
// @uses gradient color

// Approximate visible-spectrum colour for x in [0,1] (violet -> red).
vec3 spectrum(float x) {
    x = clamp(x, 0.0, 1.0);
    vec3 c = vec3(smoothstep(0.45, 0.75, x) + 0.6 * smoothstep(0.15, 0.0, x),
                  smoothstep(0.15, 0.45, x) * smoothstep(0.85, 0.6, x),
                  smoothstep(0.55, 0.15, x));
    return c;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float s = (p.x * 0.5 + p.y) * 1.2 + 0.08 * gnoise(p * 2.0 + t * 0.05) - t * 0.03;
    float band = fract(s);
    vec3 col = spectrum(band) * (0.25 + 0.1 * sin(s * 6.2831 * 0.5)) ;
    col *= smoothstep(0.0, 0.08, band) * smoothstep(1.0, 0.92, band) * 0.7 + 0.3;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
