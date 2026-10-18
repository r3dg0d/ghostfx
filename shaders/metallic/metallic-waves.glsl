// @id metallic-waves
// @name Metallic Waves
// @category metallic
// @description A sheet of liquid silver rolls in long silky waves, catching bands of light along every crest.
// @tags metal, waves, silver, silk, elegant
// @mode background
// @uses lighting
// @color PRIMARY #D9DEE8
// @color SECONDARY #0C0D11
// @color ACCENT #8C94FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Analytic slope of a sum of travelling waves.
    vec2 g = vec2(0.0);
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 d = vec2(cos(fi * 0.7 + 0.3), sin(fi * 0.7 + 0.3));
        float k = 3.0 + fi * 2.2;
        float a = 0.06 / (1.0 + fi);
        g += d * k * a * cos(dot(p, d) * k - t * (0.5 + 0.2 * fi));
    }
    vec3 n = normalize(vec3(-g, 1.0));
    vec3 r = reflect(vec3(0.0, 0.0, -1.0), n);
    float bands = pow(0.5 + 0.5 * sin(r.x * 6.0 + r.y * 2.0), 8.0);
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.6, 0.5 + 0.5 * r.y);
    col += GFX_PRIMARY * bands * 0.6 + GFX_ACCENT * pow(max(r.x, 0.0), 3.0) * 0.25;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
