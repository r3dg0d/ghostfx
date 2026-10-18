// @id rgb-split
// @name RGB Split
// @category glitch
// @description Red, green and blue channels drift apart toward the screen edges, rotating slowly like a misaligned lens.
// @tags glitch, chromatic, aberration, rgb, subtle
// @mode post
// @uses crt
// @distorts true
// @param AMOUNT float 3.0 0.0 12.0 Channel separation at the edges in pixels (at 1440p)
// @param CENTER float 0.5 0.0 1.0 How much the centre is spared
// @preset subtle AMOUNT=1.5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec2 c = uv - 0.5;
    float r = length(c * vec2(gfx_aspect(), 1.0));
    float fall = mix(1.0, smoothstep(0.0, 0.8, r), P_CENTER);
    vec2 dir = vec2(cos(t * 0.3), sin(t * 0.3));
    vec2 off = (dir * 0.5 + normalize(c + 1e-4) * 0.5) * P_AMOUNT * gfx_dpi() * fall / iResolution.xy;
    vec3 col = term_chroma(uv, off * GFX_DISTORT_TEXT * GFX_INTENSITY);
    fragColor = gfx_post_k(gfx_term(uv), col, 1.0);
}
