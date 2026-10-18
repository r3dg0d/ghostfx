// @id reality-warp
// @name Reality Warp
// @category portals
// @description Invisible masses drift across the window, pinching and swirling the fabric of space and the text along with it.
// @tags warp, distortion, gravity, spacetime, surreal
// @mode distort
// @uses sdf
// @distorts true
// @color PRIMARY #7A6BFF
// @color SECONDARY #05050B
// @color ACCENT #FF7AE0
// @param STRENGTH float 1.0 0.0 3.0 Warp strength
// @preset subtle STRENGTH=0.4

vec2 warp(vec2 p, float t) {
    vec2 off = vec2(0.0);
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * (0.07 + 0.03 * fi) + fi * 2.0) * 0.7, cos(t * (0.05 + 0.02 * fi) + fi * 1.3) * 0.35);
        vec2 d = p - c;
        float r2 = dot(d, d);
        float pull = 0.004 / (r2 + 0.01);                     // pinch toward the mass
        float swirl = 0.6 * exp(-r2 * 30.0);                  // and twist around it
        off += -d * pull + (gfx_rot(swirl) * d - d);
    }
    return off * P_STRENGTH;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 off = warp(p, t);
    vec2 q = p + off;
    // Spacetime grid revealing the warp.
    float g = grid_lines(q * 12.0, 1.2 * gfx_dpi());
    float k = clamp(length(off) * 8.0, 0.0, 1.0);
    vec3 col = GFX_SECONDARY + mix(GFX_PRIMARY, GFX_ACCENT, k) * g * (0.18 + 0.5 * k);
    vec4 term = gfx_term(uv + gfx_text_offset(off / vec2(gfx_aspect(), 1.0) * 0.5) / max(GFX_INTENSITY, 1e-3));
    fragColor = gfx_compose(uv, term, col);
}
