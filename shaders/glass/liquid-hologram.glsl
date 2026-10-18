// @id liquid-hologram
// @name Liquid Hologram
// @category glass
// @description A pane of rippling holographic liquid: iridescent bands slosh across it under fine scanlines.
// @tags hologram, liquid, iridescent, scanlines, futuristic
// @mode background
// @uses gradient color
// @color PRIMARY #8CF5FF
// @color SECONDARY #05060C

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float h = gnoise(p * 2.0 + vec2(t * 0.2, 0.0)) + 0.5 * gnoise(p * 4.0 - vec2(0.0, t * 0.3)) + 0.3 * sin(p.x * 5.0 + t);
    vec3 irid = iridescence(h * 0.6 + p.y * 0.3 + t * 0.03);
    vec3 col = GFX_SECONDARY + irid * (0.15 + 0.15 * smoothstep(0.2, 0.8, h));
    col += GFX_PRIMARY * pow(max(sin(h * 9.0), 0.0), 12.0) * 0.25;
    col *= 0.85 + 0.15 * sin(fragCoord.y / gfx_dpi() * 2.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
