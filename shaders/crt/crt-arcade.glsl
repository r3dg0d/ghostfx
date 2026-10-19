// @id crt-arcade
// @name CRT Arcade
// @category crt
// @description A punchy arcade cabinet monitor: saturated colours, chunky shadow mask, mild curve and a bezel lit by the screen.
// @tags crt, arcade, colorful, retro, bezel
// @mode post
// @uses crt sdf distortion
// @distorts true
// @animated false
// @param SATURATE float 1.4 1.0 2.0 Colour boost
// @param CURVE float 0.025 0.0 0.12 Barrel curvature

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float k = P_CURVE * GFX_DISTORT_TEXT;
    vec2 cuv = barrel((uv - 0.5) * (1.0 + k * 0.8 + 0.04 * GFX_DISTORT_TEXT) + 0.5, k);
    vec4 term = gfx_term(cuv);
    vec3 col = gfx_straight(term);
    float l = gfx_luma(col);
    col = max(mix(vec3(l), col, P_SATURATE), 0.0) + max(term_bloom(cuv, 3.0) - GFX_TERM_BG, 0.0) * 0.4;
    col *= shadow_mask(fragCoord, 0.45);
    col *= scanline(cuv.y * iResolution.y, 1.0 / (4.0 * gfx_dpi()), 0.5);
    col *= 1.2;

    vec2 c = (cuv - 0.5) * vec2(gfx_aspect(), 1.0);
    float d = sd_box(c, vec2(0.5 * gfx_aspect(), 0.5) - 0.03) - 0.03;
    float inside = 1.0 - smoothstep(-0.002, 0.002, d);
    // Bezel lit by the nearest screen edge colour.
    vec3 edge = term_bloom(clamp(cuv, 0.02, 0.98), 30.0);
    vec3 bezel = vec3(0.02) + edge * 0.35 * exp(-max(d, 0.0) * 25.0);
    col = mix(bezel, col, inside);
    fragColor = gfx_post_k(term, col, mix(1.0, GFX_INTENSITY, inside));
}
