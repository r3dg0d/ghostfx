// @id cyber-glitch
// @name Cyber Glitch
// @category glitch
// @description Neon magenta and cyan glitch slices tear across a dark synth grid, as if the terminal is being hacked.
// @tags glitch, neon, cyberpunk, magenta, cyan
// @mode glow
// @uses hash
// @flashing true
// @distorts true
// @color PRIMARY #FF2BD6
// @color SECONDARY #07030F
// @color ACCENT #22F2FF
// @param RATE float 0.35 0.0 1.0 Glitch frequency

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float tick = floor(t * 10.0);
    float burst = step(1.0 - P_RATE, hash11(floor(t * 1.5) + 0.37));
    float row = floor(uv.y * 24.0);
    float h = hash12(vec2(row, tick));
    float on = burst * step(0.7, h);
    float shift = (h - 0.85) * 0.12 * on * GFX_DISTORT_TEXT;

    // Background: faint neon grid.
    vec2 g = abs(fract(p * 12.0) - 0.5);
    float grid = smoothstep(0.48, 0.5, max(g.x, g.y));
    vec3 fx = GFX_SECONDARY + mix(GFX_PRIMARY, GFX_ACCENT, uv.x) * grid * 0.12;
    fx += mix(GFX_PRIMARY, GFX_ACCENT, step(0.85, h)) * on * 0.5;

    vec4 term = gfx_term(uv + vec2(shift, 0.0));
    // Slice tint applies to the glyphs too: a neon wash on the glitched rows.
    vec3 light = mix(GFX_PRIMARY, GFX_ACCENT, step(0.85, h)) * on * gfx_flash(0.35);
    fragColor = gfx_compose_glow(uv, term, fx, light);
}
