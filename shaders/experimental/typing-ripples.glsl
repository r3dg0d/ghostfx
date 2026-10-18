// @id typing-ripples
// @name Typing Ripples
// @category experimental
// @description A calm rainbow gradient that reacts to you: every keystroke sends a coloured ripple out from the cursor.
// @tags reactive, cursor, typing, rainbow, ripples, interactive
// @mode background
// @uses color
// @color PRIMARY #7C5CFF
// @color SECONDARY #0A0912
// @color ACCENT #FF7AC8
// @limitation Uses the cursor uniforms (Ghostty 1.2+); ripples start whenever the cursor moves or changes colour.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Base: a slow, dim rainbow sweep.
    float h = fract((p.x + p.y) * 0.15 + t * 0.02);
    vec3 col = GFX_SECONDARY + hsv2rgb(vec3(h, 0.6, 0.12));
    // Ripple from the cursor since its last change.
    float age = gfx_cursor_age() * GFX_SPEED;
    vec2 c = (gfx_cursor_center() - 0.5 * iResolution.xy) / iResolution.y;
    float r = length(p - c);
    float front = age * 0.6;
    float ring = exp(-pow((r - front) * 40.0, 2.0)) * exp(-age * 1.6);
    float glow_ = exp(-r * 12.0) * exp(-age * 3.0);
    vec3 rc = hsv2rgb(vec3(fract(h + r * 0.8), 0.7, 1.0));
    col += rc * ring * 0.8 + mix(GFX_PRIMARY, GFX_ACCENT, 0.5) * glow_ * 0.4;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
