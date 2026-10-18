// @id water-refraction
// @name Water Refraction
// @category ocean
// @description The terminal seen through a thin layer of moving water: a gentle wobble with soft light beneath.
// @tags water, refraction, distortion, subtle, calm
// @mode distort
// @uses gradient value
// @distorts true
// @color PRIMARY #0F3B57
// @color SECONDARY #071B29
// @color ACCENT #8FE3FF
// @param WOBBLE float 1.0 0.0 3.0 Text wobble amount (pixels at 1440p)
// @preset subtle WOBBLE=0.6

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec2 q = p * 3.0;
    vec2 flow = vec2(gnoise(q + vec2(t * 0.3, 0.0)), gnoise(q + vec2(7.1, -t * 0.27)));
    flow += 0.5 * vec2(gnoise(q * 2.3 - t * 0.2), gnoise(q * 2.3 + 3.0 + t * 0.25));
    vec2 off = flow * (2.5 * P_WOBBLE * gfx_dpi()) / iResolution.xy;

    // Soft refracted light patterns behind the text.
    float l = vnoise(q * 2.0 + flow * 2.0 + t * 0.2);
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, l);
    col += GFX_ACCENT * pow(l, 4.0) * 0.4;

    vec4 term = gfx_term(uv + gfx_text_offset(off));
    fragColor = gfx_compose(uv, term, col);
}
