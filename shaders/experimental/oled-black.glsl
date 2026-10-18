// @id oled-black
// @name OLED Black
// @category experimental
// @description True black with a few hair-thin light filaments drifting slowly; the pattern keeps moving so no pixel stays lit for long.
// @tags oled, black, minimal, subtle, dark, burn-in
// @mode background
// @uses hash value
// @color PRIMARY #6B7BFF
// @color SECONDARY #000000
// @color ACCENT #FF6BD5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Three filaments: smooth curves whose path wanders over minutes.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float y = 0.35 * sin(p.x * (1.2 + fi * 0.4) + t * (0.05 + 0.02 * fi) + fi * 2.0)
                + 0.1 * (vnoise(vec2(p.x * 2.0 + fi * 10.0, t * 0.03)) - 0.5);
        float d = abs(p.y - y);
        float fade = 0.5 + 0.5 * sin(t * 0.07 + fi * 2.1);
        col += mix(GFX_PRIMARY, GFX_ACCENT, fi * 0.5) * (smoothstep(1.5 * gfx_pxsize(), 0.0, d) * 0.5 + exp(-d * 400.0) * 0.15) * fade;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
