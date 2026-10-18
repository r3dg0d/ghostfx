// @id moonlight
// @name Moonlight
// @category nature
// @description A full moon glows through thin, slowly drifting clouds that light up silver as they pass in front of it.
// @tags moon, night, clouds, silver, calm
// @mode background
// @uses fbm hash
// @color PRIMARY #E2E8F5
// @color SECONDARY #050913
// @color ACCENT #4F5F80
// @param X float 0.45 -0.8 0.8 Moon horizontal position

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 m = vec2(P_X, 0.2);
    float d = length(p - m);
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.3 * exp(-d * 2.5);
    vec2 sg = p * 70.0;
    col += vec3(0.7) * step(0.99, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5)) * smoothstep(0.15, 0.5, d);
    // Moon disc with soft maria.
    float maria = fbm((p - m) * 12.0 + 3.0);
    col = mix(col, GFX_PRIMARY * (0.85 - 0.25 * smoothstep(0.5, 0.75, maria)), smoothstep(0.075, 0.072, d));
    col += GFX_PRIMARY * (0.18 * exp(-d * 10.0) + 0.08 * exp(-d * 3.0));
    // Thin clouds, brighter where they cross the moonlight.
    float cl = fbm(vec2(p.x * 1.8 - t * 0.02, p.y * 4.0) + 0.3 * fbm(p * 3.0 + t * 0.01));
    float cm = smoothstep(0.45, 0.8, cl);
    vec3 cc = mix(GFX_ACCENT * 0.4, GFX_PRIMARY * 0.8, exp(-d * 4.0));
    col = mix(col, cc, cm * 0.7);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
