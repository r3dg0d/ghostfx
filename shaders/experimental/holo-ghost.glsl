// @id holo-ghost
// @name Holographic Ghost
// @category experimental
// @description A glitching holographic figure flickers in the corner of the screen: a scanlined bust that tears, splits and re-forms.
// @tags hologram, ghost, glitch, figure, cyan, sci-fi
// @mode background
// @uses sdf hash
// @flashing true
// @color PRIMARY #5CF0FF
// @color SECONDARY #02060A
// @color ACCENT #FF4FD0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.55, -0.08);
    // Glitch: random horizontal tears of the figure.
    float row = floor(c.y * 40.0);
    float tear = step(0.92, hash12(vec2(row, floor(t * 8.0)))) * (hash12(vec2(row, floor(t * 8.0) + 1.0)) - 0.5) * 0.05;
    tear *= GFX_REDUCED_FLASH > 0.5 ? 0.3 : 1.0;
    vec2 q = c - vec2(tear, 0.0);
    // Bust: head + shoulders.
    float head = length((q - vec2(0.0, 0.12)) * vec2(1.0, 0.85)) - 0.08;
    float body = sd_box(q - vec2(0.0, -0.08), vec2(0.13 - 0.15 * max(q.y + 0.04, 0.0), 0.09)) - 0.03;
    float d = smin(head, body, 0.04);
    float fill = smoothstep(0.004, -0.004, d);
    float rim = smoothstep(0.006, 0.0, abs(d));
    float scan = 0.55 + 0.45 * sin(fragCoord.y / gfx_dpi() * 1.8 - t * 6.0);
    float flick = 1.0 - gfx_flash(0.5 * step(0.9, hash11(floor(t * 10.0))));
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * (fill * 0.18 * scan + rim * 0.7) * flick;
    col += GFX_ACCENT * fill * step(0.96, hash12(vec2(row, floor(t * 20.0)))) * 0.4;
    col += GFX_PRIMARY * 0.06 * exp(-length((c - vec2(0.0, -0.22)) * vec2(1.0, 5.0)) * 8.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
