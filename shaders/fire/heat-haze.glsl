// @id heat-haze
// @name Heat Haze
// @category fire
// @description Rising thermal shimmer wobbles the bottom of the terminal like air over hot asphalt, with a faint amber glow.
// @tags heat, distortion, haze, subtle, warm
// @mode distort
// @uses value gradient
// @distorts true
// @color PRIMARY #FF8A3D
// @color SECONDARY #120A07
// @color ACCENT #FFC27A
// @param STRENGTH float 1.0 0.0 3.0 Shimmer amplitude
// @param REACH float 0.6 0.2 1.0 How far up the screen the haze rises
// @preset subtle STRENGTH=0.6

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float fall = smoothstep(P_REACH, 0.0, uv.y);
    vec2 q = vec2(p.x * 14.0, p.y * 9.0 - t * 2.2);
    vec2 w = vec2(gnoise(q), gnoise(q * 1.3 + 5.0)) + 0.5 * vec2(gnoise(q * 2.7 + t), gnoise(q * 2.4 - t));
    vec2 off = w * vec2(1.0, 0.6) * fall * P_STRENGTH * 3.0 * gfx_dpi() / iResolution.xy;

    vec3 col = mix(GFX_SECONDARY, GFX_SECONDARY + GFX_PRIMARY * 0.25, fall);
    col += GFX_ACCENT * 0.06 * fall * vnoise(q * 0.5);

    vec4 term = gfx_term(uv + gfx_text_offset(off));
    fragColor = gfx_compose(uv, term, col);
}
