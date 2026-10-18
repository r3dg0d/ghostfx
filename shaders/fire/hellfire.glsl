// @id hellfire
// @name Hellfire
// @category fire
// @description An infernal sea of churning red fire and black smoke, with embers spiralling up through the gloom.
// @tags fire, hell, dark, red, smoke, embers, intense
// @mode background
// @uses fbm color particles
// @color PRIMARY #4A0000
// @color SECONDARY #E2290B
// @color ACCENT #FFB347

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec2 q;
    float f = warped_fbm(p * 1.8 + vec2(0.0, -t * 0.25), t * 0.6, q);
    float heat = f * 1.3 - (p.y + 0.5) * 0.65;
    float smoke = smoothstep(0.35, 0.75, q.x) * smoothstep(-0.2, 0.4, p.y);

    vec3 col = mix(vec3(0.01, 0.0, 0.0), GFX_PRIMARY, smoothstep(0.0, 0.35, heat));
    col = mix(col, GFX_SECONDARY, smoothstep(0.3, 0.7, heat));
    col = mix(col, GFX_ACCENT, smoothstep(0.7, 1.1, heat));
    col *= 1.0 - smoke * 0.85;

    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        vec2 e = p * (22.0 + fi * 16.0);
        e += vec2(sin(t + p.y * 4.0 + fi) * 0.8, -t * (2.0 + fi));
        vec2 c = particle_cell(e, 0.1, 0.8);
        col += GFX_ACCENT * c.x * step(0.7, c.y) * (0.8 + 0.2 * sin(t * 8.0 + c.y * 40.0));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
