// @id iridescent-metal
// @name Iridescent Metal
// @category metallic
// @description Heat-tinted metal like bismuth or anodised titanium, thin-film colours sliding across its surface.
// @tags iridescent, metal, rainbow, bismuth, oil-slick
// @mode background
// @uses gradient lighting color
// @color PRIMARY #8F9BB3
// @color SECONDARY #0A0A0F
// @color ACCENT #FFFFFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.8;
    float t = gfx_time();
    float h = gnoise(p * 1.2 + t * 0.04) + 0.5 * gnoise(p * 2.6 - t * 0.03);
    float e = 0.01;
    float hx = gnoise((p + vec2(e, 0.0)) * 1.2 + t * 0.04) + 0.5 * gnoise((p + vec2(e, 0.0)) * 2.6 - t * 0.03);
    float hy = gnoise((p + vec2(0.0, e)) * 1.2 + t * 0.04) + 0.5 * gnoise((p + vec2(0.0, e)) * 2.6 - t * 0.03);
    vec3 n = height_normal(h, hx, hy, e, 0.2);
    // Film thickness from height plus view angle drives the interference hue.
    float film = h * 0.8 + (1.0 - n.z) * 3.0 + t * 0.02;
    vec3 tint = iridescence(film);
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.4, 0.5 + 0.5 * h);
    col = mix(col, tint * 0.7, 0.45);
    vec3 l = normalize(vec3(0.4, 0.6, 1.0));
    col += GFX_ACCENT * blinn(n, l, vec3(0.0, 0.0, 1.0), 60.0) * 0.5;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
