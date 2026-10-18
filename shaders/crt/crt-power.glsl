// @id crt-power
// @name CRT Power
// @category crt
// @description An old tube that powers down when the window loses focus, collapsing to a glowing line and dot, then bursts back on when you return.
// @tags crt, power, focus, retro, animation, tube
// @mode post
// @uses crt
// @flashing true
// @distorts true
// @limitation Ghostty only redraws unfocused terminals when their content changes, unless custom-shader-animation = always.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float since = (iTime - GFX_TIME_FOCUS) * GFX_SPEED;
    // Focused: power-on (0 -> 1 over 0.5 s). Unfocused: power-off.
    float on = GFX_FOCUSED > 0 ? smoothstep(0.0, 0.5, since) : 1.0 - smoothstep(0.0, 0.6, since);
    if (GFX_REDUCED_MOTION > 0.5) on = GFX_FOCUSED > 0 ? 1.0 : 0.15;
    float sy = mix(0.004, 1.0, smoothstep(0.25, 1.0, on));
    float sx = mix(0.01, 1.0, smoothstep(0.0, 0.25, on));
    vec2 c = uv - 0.5;
    vec2 q = vec2(c.x / sx, c.y / sy) + 0.5;
    float inside = step(abs(c.x), sx * 0.5) * step(abs(c.y), sy * 0.5);
    vec4 term = gfx_term(q);
    vec3 col = gfx_straight(term) * inside;
    float collapsed = 1.0 - smoothstep(0.2, 0.6, on);
    col += vec3(gfx_flash(1.0)) * collapsed * exp(-abs(c.y) * iResolution.y / (2.0 * gfx_dpi()) / sx) * step(abs(c.x), sx * 0.5);
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.25);
    fragColor = gfx_post_k(gfx_term(uv), mix(gfx_straight(gfx_term(uv)), col, GFX_DISTORT_TEXT), GFX_INTENSITY);
}
