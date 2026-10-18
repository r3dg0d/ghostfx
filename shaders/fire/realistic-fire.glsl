// @id realistic-fire
// @name Realistic Fire
// @category fire
// @description A wall of turbulent flames licking up from the bottom of the screen, with a white-hot base and smoky tips.
// @tags fire, flames, warm, orange, intense
// @mode background
// @uses fbm color
// @color PRIMARY #7A0E02
// @color SECONDARY #FF5A0A
// @color ACCENT #FFE7A3
// @param HEIGHT float 0.55 0.2 1.0 Flame height as a fraction of the screen
// @preset subtle HEIGHT=0.35

vec3 fire_ramp(float h) {
    vec3 c = mix(vec3(0.0), GFX_PRIMARY, smoothstep(0.0, 0.25, h));
    c = mix(c, GFX_SECONDARY, smoothstep(0.2, 0.55, h));
    c = mix(c, GFX_ACCENT, smoothstep(0.55, 0.95, h));
    return c;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float y = uv.y / P_HEIGHT;
    vec2 q = vec2(p.x * 3.0, y * 2.2 - t * 1.7);
    q.x += 0.6 * fbm(q * 0.6 + vec2(0.0, t * 0.4)) - 0.3;
    float n = fbm(q);
    float n2 = turbulence(q * 1.8 + vec2(3.1, -t * 0.6));
    float heat = n * 1.25 + n2 * 0.35 - y * 1.05 + 0.15;
    heat = clamp(heat, 0.0, 1.0);
    vec3 col = fire_ramp(pow(heat, 1.2) * 1.05);

    // Smoke above the flames.
    float smoke = fbm(vec2(p.x * 2.0, y * 1.2 - t * 0.5)) * smoothstep(0.6, 1.3, y) * smoothstep(2.4, 1.2, y);
    col += vec3(0.06, 0.05, 0.05) * smoke;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
