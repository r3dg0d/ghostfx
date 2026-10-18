// @id plasma-field
// @name Plasma Field
// @category fire
// @description Shimmering sheets of magenta and cyan energy plasma, folding through each other with bright filaments.
// @tags plasma, energy, colorful, neon, abstract
// @mode background
// @uses gradient color
// @color PRIMARY #FF2BD6
// @color SECONDARY #1B0B3A
// @color ACCENT #22E4FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 2.0;
    float t = gfx_time() * 0.6;

    // Classic plasma terms, domain-warped by gradient noise.
    vec2 w = p + 0.6 * vec2(gnoise(p * 1.3 + t * 0.3), gnoise(p * 1.3 - t * 0.25 + 3.0));
    float v = sin(w.x * 2.1 + t) + sin(w.y * 2.7 - t * 1.3)
            + sin((w.x + w.y) * 1.7 + t * 0.7) + sin(length(w) * 3.0 - t * 1.6);
    v *= 0.25;
    float fil = pow(1.0 - abs(sin(v * 6.2831)), 12.0);

    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, smoothstep(-0.6, 0.6, v));
    col = mix(col, GFX_ACCENT, smoothstep(0.3, 1.0, sin(v * 3.0 + t) * 0.5 + 0.5) * 0.7);
    col += vec3(1.0) * fil * 0.35;
    fragColor = gfx_compose(uv, gfx_term(uv), col * 0.85);
}
