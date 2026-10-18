// @id oil-slick
// @name Oil Slick
// @category liquid
// @description A film of oil on dark wet asphalt, its rainbow interference swirls slowly stretching and folding.
// @tags oil, rainbow, iridescent, swirl, dark
// @mode background
// @uses fbm color
// @color SECONDARY #050506

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.4;
    float t = gfx_time() * 0.2;
    vec2 q;
    float thick = warped_fbm(p, t, q);
    // Thin-film colour from thickness; dark where the film is thin.
    vec3 film = iridescence(thick * 2.5 + q.x);
    float amount = smoothstep(0.3, 0.6, thick);
    vec3 col = GFX_SECONDARY + film * amount * 0.28 + vec3(0.02) * fbm(p * 20.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
