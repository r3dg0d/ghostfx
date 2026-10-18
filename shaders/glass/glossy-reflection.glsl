// @id glossy-reflection
// @name Glossy Reflection
// @category glass
// @description A glossy screen: a broad diagonal sheen glides slowly across, with a faint reflected room gradient behind it.
// @tags glossy, reflection, sheen, subtle, elegant
// @mode glow
// @uses value
// @color PRIMARY #FFFFFF
// @color SECONDARY #0C0E14
// @color ACCENT #A9B8FF
// @param SHEEN float 0.6 0.0 1.0 Sheen brightness
// @param PERIOD float 9.0 3.0 30.0 Seconds per sweep

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Reflected "room": a soft vertical gradient and a window-shaped glow.
    vec3 fx = mix(GFX_SECONDARY, GFX_SECONDARY + GFX_ACCENT * 0.12, smoothstep(-0.5, 0.5, p.y));
    vec2 w = p - vec2(-0.5, 0.2);
    fx += GFX_ACCENT * 0.14 * smoothstep(0.2, 0.0, max(abs(w.x) - 0.25, abs(w.y) - 0.15));
    fx += (vnoise(p * 3.0 + t * 0.05) - 0.5) * 0.02;
    // Moving sheen band (two widths for a soft core + broad falloff).
    float s = (p.x + p.y * 0.6) / gfx_aspect();
    float pos = fract(t / P_PERIOD) * 2.4 - 1.2;
    float band = exp(-pow((s - pos) * 9.0, 2.0)) * 0.7 + exp(-pow((s - pos) * 3.0, 2.0)) * 0.3;
    vec3 light = GFX_PRIMARY * band * P_SHEEN * 0.4;
    fragColor = gfx_compose_glow(uv, gfx_term(uv), fx, light);
}
