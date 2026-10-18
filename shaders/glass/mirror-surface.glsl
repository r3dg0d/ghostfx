// @id mirror-surface
// @name Mirror Surface
// @category glass
// @description The lower part of the window turns into a dark polished floor that mirrors the terminal above, rippling gently.
// @tags mirror, reflection, glossy, elegant, minimal
// @mode background
// @uses gradient
// @color PRIMARY #B8C4FF
// @color SECONDARY #07080D
// @color ACCENT #3A4370
// @param HORIZON float 0.3 0.1 0.6 Height of the mirror line (fraction of screen from the bottom)
// @param RIPPLE float 1.0 0.0 3.0 Ripple strength

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hz = P_HORIZON;
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.4, smoothstep(hz + 0.4, hz, uv.y));
    if (uv.y < hz) {
        float d = hz - uv.y;
        vec2 w = vec2(gnoise(vec2(p.x * 8.0, d * 40.0 - t * 0.5)), 0.0) * 0.004 * P_RIPPLE * (1.0 + d * 6.0);
        vec2 ruv = vec2(uv.x + w.x, hz + d * 1.0 + w.x * 0.5);
        vec4 r = gfx_term(ruv);
        float m = gfx_text_mask(r);
        vec3 refl = gfx_straight(r) * m;
        float fade = exp(-d * 6.0);
        col += refl * fade * 0.45;
        col += GFX_PRIMARY * 0.05 * exp(-d * 30.0);
    }
    col += GFX_PRIMARY * exp(-abs(uv.y - hz) * iResolution.y / (2.0 * gfx_dpi())) * 0.15;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
