// @id quantum-particles
// @name Quantum Particles
// @category particles
// @description Fuzzy probability clouds flicker in and out of existence while entangled pairs pulse in sync over interference fringes.
// @tags quantum, abstract, science, particles, blue
// @mode background
// @uses hash value sdf
// @color PRIMARY #7AA2FF
// @color SECONDARY #03050C
// @color ACCENT #FF6BD5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Two-slit style interference from two moving sources.
    vec2 s1 = vec2(-0.5 + 0.1 * sin(t * 0.2), 0.1 * cos(t * 0.3));
    vec2 s2 = vec2(0.5 + 0.1 * cos(t * 0.25), -0.1 * sin(t * 0.2));
    float k = 55.0;
    float wv = sin(length(p - s1) * k - t * 2.0) + sin(length(p - s2) * k - t * 2.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * 0.05 * wv * wv;

    // Probability clouds: particles exist only while their tunnelling clock is "on".
    vec2 q = p * 6.0;
    vec2 id = floor(q);
    vec2 f = fract(q) - 0.5;
    float h = hash12(id);
    float clock = floor(t * (0.4 + h) + h * 10.0);
    vec2 pos = (hash22(id + clock) - 0.5) * 0.6;
    float exist = step(0.55, hash12(id + clock * 1.7));
    float cloud = exp(-dot(f - pos, f - pos) * 60.0) * (0.7 + 0.3 * vnoise(f * 20.0 + t * 3.0));
    float core = smoothstep(0.04, 0.0, length(f - pos));
    col += mix(GFX_PRIMARY, GFX_ACCENT, h) * exist * (cloud * 0.5 + core);

    // Entangled pair: mirrored positions, same phase, faint link.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 a = vec2(0.6 * sin(t * 0.3 + fi * 2.1), 0.35 * cos(t * 0.23 + fi * 1.3));
        float ph = 0.5 + 0.5 * sin(t * 3.0 + fi * 2.0);
        float link = smoothstep(0.003, 0.0, abs(dot(p, normalize(vec2(-a.y, a.x))))) * step(length(p), length(a));
        col += GFX_ACCENT * ph * (glow(length(p - a), 0.01) + glow(length(p + a), 0.01)) * 0.6;
        col += GFX_PRIMARY * link * 0.25 * ph;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
