// @id carbon-fiber
// @name Carbon Fiber
// @category metallic
// @description Glossy 2x2 twill carbon weave, its tows catching a slow sweep of light under a clear coat.
// @tags carbon, fiber, weave, dark, subtle, premium
// @mode background
// @uses value
// @color PRIMARY #3A3F48
// @color SECONDARY #08090B
// @color ACCENT #C8D2E0
// @param SCALE float 60.0 20.0 160.0 Weave cells per screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_SCALE;
    vec2 id = floor(g);
    vec2 f = fract(g);
    // 2x2 twill: the over/under pattern shifts by one cell per row.
    float over = step(1.0, mod(id.x + id.y, 4.0)) * step(mod(id.x + id.y, 4.0), 2.0);
    // Tow profile: rounded across its width, with fibres along its length.
    float across = over > 0.5 ? f.y : f.x;
    float along = over > 0.5 ? f.x : f.y;
    float profile = sin(across * 3.1416);
    float fibres = 0.85 + 0.15 * vnoise(vec2(along * 4.0, across * 40.0 + id.x));
    // Anisotropic highlight: each direction lights up at a different light angle.
    float la = sin(t * 0.2) * 0.5 + 0.5;
    float hl = over > 0.5 ? la : 1.0 - la;
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * profile * fibres * (0.35 + 0.65 * hl);
    // Clear-coat sweep.
    float sweep = exp(-pow((p.x - p.y * 0.5) - (fract(t * 0.05) * 3.0 - 1.5) * gfx_aspect(), 2.0) * 8.0);
    col += GFX_ACCENT * sweep * 0.08;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
