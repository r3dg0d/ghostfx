// @id magic-dust
// @name Magic Dust
// @category particles
// @description A ribbon of golden sparkles winds across the screen, each glint flaring into a four-pointed star.
// @tags magic, sparkle, gold, particles, fantasy
// @mode background
// @uses hash
// @color PRIMARY #FFD36E
// @color SECONDARY #0E0A1A
// @color ACCENT #FFF6D6

float star4(vec2 d, float s) {
    vec2 a = abs(d) / s;
    return exp(-a.x * 6.0) * exp(-a.y * 60.0) + exp(-a.y * 6.0) * exp(-a.x * 60.0) + exp(-length(a) * 8.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;

    // The ribbon path the dust follows.
    float path = 0.18 * sin(p.x * 2.2 + t * 0.6) + 0.08 * sin(p.x * 5.1 - t * 0.9);
    float band = exp(-pow((p.y - path) / 0.16, 2.0));
    col += GFX_PRIMARY * band * 0.12;

    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float sc = 18.0 + fi * 10.0;
        vec2 q = vec2(p.x * sc - t * (1.5 + fi), (p.y - path) * sc);
        vec2 id = floor(q);
        vec2 h = hash22(id + fi * 5.0);
        if (h.x > 0.3) continue;
        vec2 f = fract(q) - 0.5 - (hash22(id + 2.0) - 0.5) * 0.6;
        float life = pow(0.5 + 0.5 * sin(t * (2.0 + h.y * 4.0) + h.x * 40.0), 4.0);
        float s = star4(f, 0.35 + 0.4 * life) * life;
        col += mix(GFX_PRIMARY, GFX_ACCENT, life) * s * exp(-pow((p.y - path) / 0.22, 2.0)) * 2.2;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
