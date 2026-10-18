// @id brushed-steel
// @name Brushed Steel
// @category metallic
// @description Horizontally brushed stainless steel with fine streaks and a soft anisotropic highlight that slides with the light.
// @tags steel, brushed, metal, industrial, subtle
// @mode background
// @uses value hash
// @color PRIMARY #B9C0C8
// @color SECONDARY #2A2E33
// @color ACCENT #FFFFFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Streaks: noise stretched heavily along x.
    float s = vnoise(vec2(p.x * 3.0, p.y * 400.0)) * 0.5 + vnoise(vec2(p.x * 9.0, p.y * 1200.0)) * 0.3 + hash12(vec2(floor(fragCoord.y), 0.0)) * 0.2;
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.6, s);
    // Anisotropic highlight: a vertical band (brushing is horizontal).
    float lx = sin(t * 0.15) * 0.6 * gfx_aspect();
    float band = exp(-pow((p.x - lx) * 2.5, 2.0));
    col += GFX_ACCENT * band * (0.15 + 0.2 * s);
    col *= 0.85 + 0.15 * smoothstep(-0.6, 0.6, p.y);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
