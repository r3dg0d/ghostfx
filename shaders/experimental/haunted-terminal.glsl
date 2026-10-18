// @id haunted-terminal
// @name Haunted Terminal
// @category experimental
// @description Cold mist creeps along the edges while, every so often, a line of text shivers and leaves a faint ghostly echo.
// @tags haunted, ghost, horror, mist, eerie, halloween
// @mode distort
// @uses fbm hash
// @distorts true
// @color PRIMARY #9FC7D9
// @color SECONDARY #05080B
// @color ACCENT #6E8CFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // A random text row gets possessed for ~0.6 s every few seconds.
    float slot = floor(t / 3.5);
    float lt = fract(t / 3.5) * 3.5;
    float row = floor(hash11(slot) * 24.0);
    float hit = step(row, uv.y * 24.0) * step(uv.y * 24.0, row + 1.0) * step(lt, 0.6) * GFX_DISTORT_TEXT;
    vec2 shiver = vec2(sin(t * 60.0 + uv.y * 300.0) * 2.0 * gfx_dpi() / iResolution.x, 0.0) * hit * GFX_INTENSITY;
    vec4 term = gfx_term(uv + shiver);
    // Ghost echo: the possessed row drifts up and fades.
    vec4 echo = gfx_term(uv - vec2(0.0, lt * 0.02)) * hit;
    vec3 fx = GFX_SECONDARY;
    vec2 e2 = vec2(0.5 * gfx_aspect(), 0.5) - abs(p);
    float edge = smoothstep(0.25, 0.0, min(e2.x, e2.y));
    float mist = fbm(p * 2.5 + vec2(t * 0.05, -t * 0.03));
    fx = mix(fx, GFX_PRIMARY * 0.35, edge * smoothstep(0.3, 0.8, mist));
    vec4 c = gfx_compose(uv, term, fx);
    c.rgb += GFX_ACCENT * gfx_text_mask(echo) * (1.0 - lt / 0.6) * 0.35 * GFX_INTENSITY;
    fragColor = c;
}
