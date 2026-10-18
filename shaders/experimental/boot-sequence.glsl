// @id boot-sequence
// @name Boot Sequence
// @category experimental
// @description Each time the window gains focus, dim lines of firmware text race up the background, a memory counter ticks and then fades away.
// @tags boot, bios, retro, startup, focus, terminal
// @mode background
// @uses hash
// @color PRIMARY #9BE7FF
// @color SECONDARY #04070A
// @color ACCENT #FFD27A
// @param DURATION float 2.5 0.8 8.0 Seconds the boot animation lasts after focus

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    // Run on focus; also loop slowly so the effect is visible in previews.
    float since = mod((iTime - GFX_TIME_FOCUS) * GFX_SPEED, P_DURATION + 8.0);
    float k = since / P_DURATION;
    float alive = 1.0 - smoothstep(0.85, 1.0, k);
    vec3 col = GFX_SECONDARY;
    // Fake firmware log: rows of pseudo-glyph blocks, revealed bottom-up.
    float px = 2.0 * gfx_dpi();
    vec2 cell = floor(fragCoord / (px * vec2(4.0, 8.0)));
    vec2 f = fract(fragCoord / (px * vec2(4.0, 8.0)));
    float rowsVisible = k * iResolution.y / (px * 8.0) * 1.4;
    float lineLen = 10.0 + 50.0 * hash11(cell.y * 1.7);
    float shown = step(cell.y, rowsVisible) * step(cell.x, lineLen * min(1.0, (rowsVisible - cell.y) * 0.3));
    float ink = step(0.35, hash12(cell + floor(f * vec2(3.0, 5.0)) * 0.13)) * step(0.15, f.x) * step(0.2, f.y) * step(f.y, 0.85);
    vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, step(0.92, hash11(cell.y * 3.1)));
    col += c * ink * shown * 0.35 * alive;
    // Memory test bar at the top.
    float bar = step(abs(uv.y - 0.96), 0.006) * step(uv.x, clamp(k * 1.2, 0.0, 1.0)) * step(0.02, uv.x);
    col += GFX_ACCENT * bar * 0.6 * alive;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
