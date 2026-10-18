// @id crt-terminal-1980
// @name CRT Terminal 1980
// @category crt
// @description A 1980s video terminal in pale P4 white: deep tube curvature, glassy reflection, and a power-on warm-up each time it gains focus.
// @tags crt, 1980s, vintage, monochrome, terminal
// @mode post
// @uses crt sdf distortion
// @distorts true
// @color PRIMARY #E8F4E6
// @color SECONDARY #0B0F0C
// @color ACCENT #9FDDB0
// @param WARMUP float 1.0 0.0 1.0 Play the power-on animation when focused

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float k = 0.05 * GFX_DISTORT_TEXT;
    vec2 cuv = barrel((uv - 0.5) * (1.0 + k * 0.6) + 0.5, k);
    vec4 term = gfx_term(cuv);
    float bgl = gfx_luma(GFX_TERM_BG);
    float norm = 1.0 / max(1.0 - bgl, 0.2);
    float e = clamp((gfx_luma(gfx_straight(term)) - bgl) * norm, 0.0, 1.0);
    float halo = clamp((gfx_luma(term_bloom(cuv, 3.5)) - bgl) * norm, 0.0, 1.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * e * 0.95 + GFX_ACCENT * halo * 0.35;
    col *= scanline(cuv.y * iResolution.y, 1.0 / (3.0 * gfx_dpi()), 0.35);

    // Power-on: a bright line opens vertically over ~0.6 s after focus.
    float since = (iTime - GFX_TIME_FOCUS) * GFX_SPEED;
    if (P_WARMUP > 0.5 && GFX_REDUCED_MOTION < 0.5 && since < 0.8 && GFX_FOCUSED > 0) {
        float open_ = smoothstep(0.0, 0.6, since);
        float line = smoothstep(0.004 + 0.5 * open_, 0.0, abs(cuv.y - 0.5));
        col = mix(vec3(gfx_flash(1.0)) * line, col * open_, open_);
    }
    // Curved glass reflection.
    vec2 c = (cuv - 0.5) * vec2(gfx_aspect(), 1.0);
    col += vec3(0.05) * smoothstep(0.35, 0.0, length(c - vec2(-0.35, 0.25))) * 0.8;
    float d = sd_box(c, vec2(0.5 * gfx_aspect(), 0.5) - 0.07) - 0.07;
    float inside = 1.0 - smoothstep(-0.002, 0.002, d);
    col = mix(vec3(0.03, 0.035, 0.03), col * vignette(cuv, 0.6), inside);
    fragColor = gfx_post_k(term, col, mix(1.0, GFX_INTENSITY, inside));
}
