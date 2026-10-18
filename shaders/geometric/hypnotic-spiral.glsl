// @id hypnotic-spiral
// @name Hypnotic Spiral
// @category geometric
// @description A slowly turning Archimedean spiral in two soft tones that seems to pull the eye inward. Gentle by default.
// @tags spiral, hypnotic, optical, minimal, rotating
// @mode background
// @color PRIMARY #6E5BFF
// @color SECONDARY #0B0916
// @color ACCENT #FF7AC6
// @param ARMS float 2.0 1.0 6.0 Spiral arms
// @param TIGHTNESS float 18.0 6.0 40.0 Turns density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.38, 0.0);
    float r = length(c);
    float a = atan(c.y, c.x);
    // Integer arm count keeps the pattern continuous across atan()'s seam.
    float s = fract(a / 6.2831 * floor(P_ARMS) + r * P_TIGHTNESS * 0.5 - t * 0.15);
    float band = smoothstep(0.45, 0.5, s) * smoothstep(1.0, 0.95, s) + smoothstep(0.05, 0.0, s);
    vec3 col = mix(GFX_SECONDARY, mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.0, 0.6, r)), band * 0.6 * smoothstep(0.0, 0.08, r));
    col *= smoothstep(1.1, 0.2, r);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
