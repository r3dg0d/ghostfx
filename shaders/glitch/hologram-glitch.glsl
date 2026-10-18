// @id hologram-glitch
// @name Hologram Glitch
// @category glitch
// @description The whole terminal becomes a flickering cyan hologram: rolling scan bands, jitter and a ghostly transparency.
// @tags hologram, glitch, cyan, sci-fi, flicker
// @mode post
// @uses hash value
// @flashing true
// @distorts true
// @color PRIMARY #3FF3FF
// @color SECONDARY #010A10
// @color ACCENT #B5FFFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float jit = step(0.93, hash11(floor(t * 8.0))) * (hash11(floor(t * 30.0)) - 0.5) * 0.01 * GFX_DISTORT_TEXT;
    float lineJ = (hash12(vec2(floor(uv.y * 90.0), floor(t * 20.0))) - 0.5) * 0.0015 * GFX_DISTORT_TEXT;
    vec2 suv = uv + vec2(jit + lineJ, 0.0);
    vec4 term = gfx_term(uv);
    float bgl = gfx_luma(GFX_TERM_BG);
    float e = clamp((gfx_luma(gfx_straight(gfx_term(suv))) - bgl) / max(1.0 - bgl, 0.2), 0.0, 1.0);
    // Ghost copy offset upward.
    float g = clamp((gfx_luma(gfx_straight(gfx_term(suv + vec2(0.0, 0.006)))) - bgl) / max(1.0 - bgl, 0.2), 0.0, 1.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * (e * 0.95 + g * 0.2) + GFX_ACCENT * pow(e, 3.0) * 0.4;
    float scan = 0.85 + 0.15 * sin(fragCoord.y / gfx_dpi() * 1.2 - t * 10.0);
    float band = 1.0 + 0.25 * exp(-pow((fract(uv.y * 0.5 - t * 0.3) - 0.5) * 8.0, 2.0));
    float flick = 1.0 - gfx_flash(0.12 * step(0.9, vnoise(vec2(t * 15.0, 0.0))));
    col *= scan * band * flick;
    col += GFX_PRIMARY * 0.04;
    fragColor = gfx_post(term, col);
}
