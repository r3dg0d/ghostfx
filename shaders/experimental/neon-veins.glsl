// @id neon-veins
// @name Neon Veins
// @category experimental
// @description A branching network of neon blood vessels pulses with each heartbeat, light flowing outward through every capillary.
// @tags veins, organic, neon, pulse, red, biology
// @mode background
// @uses fbm
// @color PRIMARY #FF2E63
// @color SECONDARY #070205
// @color ACCENT #FF9EB5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = p * 2.0 + 0.3 * vec2(fbm(p * 1.5), fbm(p * 1.5 + 5.0));
    float v1 = pow(ridged(q), 7.0);
    float v2 = pow(ridged(q * 2.3 + 7.0), 14.0) * 0.7;
    float veins = v1 + v2;
    // Pulse wave radiating from the heart point.
    float r = length(p - vec2(0.6, -0.1));
    float pulse = pow(0.5 + 0.5 * sin(r * 12.0 - t * 4.0), 6.0) * exp(-r * 0.8);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * veins * (0.7 + 1.8 * pulse);
    col += GFX_ACCENT * v1 * pulse * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
