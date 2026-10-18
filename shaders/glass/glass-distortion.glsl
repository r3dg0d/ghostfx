// @id glass-distortion
// @name Glass Distortion
// @category glass
// @description Looking through an antique hand-made pane: gentle waves, trapped bubbles and a faint colour fringe that drift as you watch.
// @tags glass, antique, distortion, subtle, vintage
// @mode distort
// @uses gradient hash crt
// @distorts true
// @color PRIMARY #E7E1CF
// @color SECONDARY #0F0F0D
// @color ACCENT #A39C82
// @param WAVE float 1.0 0.0 3.0 Waviness in pixels (x2)
// @preset subtle WAVE=0.5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // The viewpoint drifts, so the (static) pane waves appear to move.
    vec2 q = p * vec2(2.0, 6.0) + vec2(t * 0.03, t * 0.01);
    float h = gnoise(q) + 0.5 * gnoise(q * 2.3 + 4.0);
    vec2 slope = vec2(gnoise(q + vec2(0.05, 0.0)) - gnoise(q - vec2(0.05, 0.0)), gnoise(q + vec2(0.0, 0.05)) - gnoise(q - vec2(0.0, 0.05)));
    vec2 off = slope * P_WAVE * 2.0 * gfx_dpi() / iResolution.xy * 10.0;
    vec2 suv = uv + gfx_text_offset(off);
    vec3 fringe = term_chroma(suv, off * 0.3 * GFX_DISTORT_TEXT);
    vec4 term = vec4(fringe * gfx_term(suv).a, gfx_term(suv).a);
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.06 * (h + 0.5);
    // Trapped bubbles.
    vec2 g = p * vec2(30.0, 60.0);
    vec2 id = floor(g);
    float b = step(0.97, hash12(id)) * smoothstep(0.25, 0.15, length((fract(g) - 0.5) * vec2(1.0, 0.5)));
    col += GFX_PRIMARY * b * 0.12;
    fragColor = gfx_compose(uv, term, col);
}
