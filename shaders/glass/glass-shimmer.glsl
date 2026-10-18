// @id glass-shimmer
// @name Glass Shimmer
// @category glass
// @description Soft iridescent highlights drift across a pane of glass like light catching it as you move.
// @tags glass, shimmer, iridescent, subtle, soft
// @mode glow
// @uses value color
// @color PRIMARY #CFE3FF
// @color SECONDARY #0C0D14
// @color ACCENT #FFC8F0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 fx = GFX_SECONDARY + GFX_PRIMARY * 0.03 * (p.y + 0.5);
    vec3 light = vec3(0.0);
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 d = normalize(vec2(1.0, 0.4 + 0.3 * fi));
        float s = dot(p, d) * (1.5 + fi) - t * (0.05 + 0.03 * fi) + fi * 0.37;
        float band = pow(0.5 + 0.5 * sin(s * 6.2831), 18.0);
        float var_ = vnoise(p * 3.0 + fi * 5.0 + t * 0.05);
        light += iridescence(s * 0.5 + var_) * band * var_ * 0.12;
        fx += mix(GFX_PRIMARY, GFX_ACCENT, var_) * band * 0.05;
    }
    fragColor = gfx_compose_glow(uv, gfx_term(uv), fx, light);
}
