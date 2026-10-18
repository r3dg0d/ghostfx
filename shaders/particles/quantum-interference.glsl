// @id quantum-interference
// @name Quantum Interference
// @category particles
// @description The double-slit experiment: single photons land one by one, gradually building up bright and dark interference fringes.
// @tags quantum, double-slit, physics, photons, science
// @mode background
// @uses hash
// @color PRIMARY #7DF0FF
// @color SECONDARY #030409
// @color ACCENT #FF7AD4
// @param CYCLE float 30.0 10.0 120.0 Seconds to build the pattern

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    // Probability density of the two-slit pattern along x (with envelope).
    float x = p.x - 0.3;
    float envelope = exp(-x * x * 6.0);
    float density = envelope * pow(cos(x * 38.0), 2.0);
    // Each cell gets a photon with probability ~ density x elapsed fraction.
    vec2 g = fragCoord / max(2.0 * gfx_dpi(), 1.0);
    vec2 id = floor(g);
    float arrival = hash12(id);
    float landed = step(arrival, k * density * 0.6) * step(abs(p.y), 0.4);
    float fresh = smoothstep(0.02, 0.0, k * density * 0.6 - arrival);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * landed * (0.5 + 0.5 * fresh);
    col += GFX_ACCENT * landed * fresh * 0.8;
    // Faint guide of the expected pattern.
    col += GFX_PRIMARY * density * 0.04 * smoothstep(0.42, 0.38, abs(p.y));
    col *= smoothstep(1.0, 0.95, k) + 0.0;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
