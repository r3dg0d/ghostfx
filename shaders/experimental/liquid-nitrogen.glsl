// @id liquid-nitrogen
// @name Liquid Nitrogen
// @category experimental
// @description Freezing white vapour pours down from the top of the window and spreads along the bottom, glittering with ice crystals.
// @tags cold, vapour, fog, ice, white, blue
// @mode background
// @uses fbm hash
// @color PRIMARY #E8F6FF
// @color SECONDARY #06101A
// @color ACCENT #5FB4FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.05;
    // Heavy vapour falls from the top and pools at the bottom.
    vec2 q = vec2(p.x * 2.0, p.y * 1.5 + t * 0.25);
    float fall = fbm(q + 0.5 * fbm(q * 2.0 - t * 0.1)) * smoothstep(0.1, 0.5, p.y);
    vec2 r = vec2(abs(p.x) * 1.5 - t * 0.08, p.y * 4.0);           // spreads outward from the centre
    float pool = fbm(r + 0.4 * fbm(r * 2.0 + t * 0.05)) * smoothstep(-0.15, -0.5, p.y);
    float v = smoothstep(0.35, 0.9, fall) + smoothstep(0.3, 0.8, pool);
    col = mix(col, GFX_PRIMARY * 0.75, clamp(v, 0.0, 1.0) * 0.8);
    col += GFX_ACCENT * 0.1 * v;
    // Ice crystals glinting inside the vapour.
    vec2 g = p * 90.0;
    vec2 id = floor(g);
    float glint = step(0.985, hash12(id)) * pow(max(sin(t * 3.0 + hash12(id + 1.0) * 40.0), 0.0), 16.0);
    col += vec3(1.0) * glint * clamp(v, 0.0, 1.0) * smoothstep(0.3, 0.0, length(fract(g) - 0.5));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
