// @id curved-crt
// @name Curved CRT
// @category crt
// @description The terminal bulges out of a rounded tube in a dark bezel, with scanlines that follow the glass curvature.
// @tags crt, curved, retro, bezel, distortion
// @mode post
// @uses crt sdf distortion
// @distorts true
// @animated false
// @param CURVE float 0.035 0.0 0.2 Barrel curvature
// @param CORNER float 0.04 0.0 0.12 Corner radius
// @param SCANLINES float 0.4 0.0 1.0 Scanline darkness
// @preset subtle CURVE=0.015
// @preset cinematic CURVE=0.07 SCANLINES=0.55

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float k = P_CURVE * GFX_DISTORT_TEXT;
    // Zoom out slightly so the curved image fits inside the bezel.
    vec2 cuv = barrel((uv - 0.5) * (1.0 + k * 0.6) + 0.5, k);
    vec4 term = gfx_term(cuv);
    vec3 col = gfx_straight(term) + term_bloom(cuv, 3.0) * 0.2;
    col *= scanline(cuv.y * iResolution.y, 1.0 / (3.0 * gfx_dpi()), P_SCANLINES);
    col *= vignette(cuv, 0.5);

    // Rounded tube mask and bezel.
    vec2 c = (cuv - 0.5) * vec2(gfx_aspect(), 1.0);
    float d = sd_box(c, vec2(0.5 * gfx_aspect(), 0.5) - P_CORNER) - P_CORNER;
    float inside = 1.0 - smoothstep(-0.002, 0.002, d);
    vec2 bc = (uv - 0.5) * vec2(gfx_aspect(), 1.0);
    vec3 bezel = vec3(0.045, 0.045, 0.05) * (0.8 + 0.4 * (0.5 - bc.y));
    bezel += gfx_straight(gfx_term(clamp(cuv, 0.0, 1.0))) * 0.06 * exp(-max(d, 0.0) * 60.0);
    col = mix(bezel, col, inside);
    fragColor = gfx_post(term, col);
}
