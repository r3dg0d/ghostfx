// @id snow-accumulation
// @name Snow Accumulation
// @category particles
// @description Snow falls behind your text and settles on it: every line of glyphs wears a soft white cap that sparkles faintly.
// @tags snow, winter, reactive, text, cozy, particles
// @mode glow
// @uses hash
// @color PRIMARY #FFFFFF
// @color SECONDARY #0B1626
// @color ACCENT #BFE3FF
// @limitation Without frame feedback the snow cannot pile up over time; caps are drawn wherever a glyph has empty space above it.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);
    vec3 fx = mix(GFX_SECONDARY, GFX_SECONDARY * 1.6, smoothstep(0.5, -0.5, p.y));
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = p * (14.0 + fi * 10.0) + vec2(sin(t * 0.5 + fi) * 0.5, t * (1.2 + fi * 0.3)) + fi * 9.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.35) continue;
        vec2 f = fract(q) - 0.5 - (hash22(id) - 0.5) * 0.5;
        fx += GFX_PRIMARY * smoothstep(0.12, 0.02, length(f)) * (0.6 - fi * 0.15);
    }
    // Snow caps: this pixel is empty, the one ~1.5px below is a glyph, and
    // the column above is empty for a few pixels.
    vec2 px = vec2(0.0, gfx_dpi() / iResolution.y);
    float here = gfx_text_mask(term);
    float below = gfx_text_mask(gfx_term(uv - px * 1.5));
    float above = max(gfx_text_mask(gfx_term(uv + px * 2.0)), gfx_text_mask(gfx_term(uv + px * 4.0)));
    float cap = (1.0 - here) * below * (1.0 - above);
    float sparkle = step(0.9, hash12(floor(fragCoord / 2.0))) * (0.5 + 0.5 * sin(t * 3.0 + hash12(floor(fragCoord)) * 30.0));
    vec3 light = mix(GFX_ACCENT, GFX_PRIMARY, sparkle) * cap * (0.9 + 0.4 * sparkle);
    fragColor = gfx_compose_glow(uv, term, fx, light);
}
