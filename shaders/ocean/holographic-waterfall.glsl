// @id holographic-waterfall
// @name Holographic Waterfall
// @category ocean
// @description A cascade made of light: columns of glowing data bars pour down and splash into a pool of scanlines.
// @tags waterfall, hologram, data, cyan, sci-fi
// @mode background
// @uses hash
// @color PRIMARY #4DF7FF
// @color SECONDARY #020509
// @color ACCENT #B56BFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    float width = 0.35;
    float x = p.x - 0.4;
    float inside = smoothstep(width, width - 0.02, abs(x));
    float cols = 60.0;
    float cid = floor(x * cols);
    float h = hash11(cid * 1.37);
    float y = p.y * 12.0 + t * (4.0 + 3.0 * h);
    float seg = floor(y);
    float bar = step(0.35, hash12(vec2(cid, seg))) * step(0.15, fract(x * cols)) * step(0.1, fract(y));
    float pool = smoothstep(-0.3, -0.45, p.y);
    vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, hash12(vec2(seg, cid)) * 0.6);
    col += c * bar * inside * (1.0 - pool) * 0.55;
    // Pool of scanlines with a splash glow.
    float lines = step(0.5, fract((p.y + 0.5) * 120.0 - t * 2.0));
    col += GFX_PRIMARY * pool * lines * 0.12 * smoothstep(0.9, 0.0, abs(x) / 0.6);
    col += GFX_PRIMARY * 0.25 * exp(-length(vec2(x * 1.5, p.y + 0.38)) * 6.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
