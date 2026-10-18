// @id supernova
// @name Supernova
// @category space
// @description A star detonates: a blinding core gives way to an expanding shell of filaments that fades before the next blast.
// @tags space, explosion, supernova, shockwave, dramatic
// @mode background
// @uses fbm
// @flashing true
// @color PRIMARY #FF5A3C
// @color SECONDARY #020106
// @color ACCENT #8FD3FF
// @param PERIOD float 14.0 6.0 40.0 Seconds between explosions

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float age = mod(t, P_PERIOD) / P_PERIOD;
    vec2 c = p - vec2(0.4, 0.05);
    float r = length(c);
    vec3 col = GFX_SECONDARY;

    float R = 0.05 + age * 0.7;
    // Filamentary shell: noise sampled in direction space (no seam).
    vec2 dir = c / max(r, 1e-4);
    float fil = fbm(dir * 3.0 + vec2(age * 2.0)) * fbm(c * 8.0 - dir * age * 3.0);
    float shell = exp(-pow((r - R) / (0.03 + 0.1 * age), 2.0));
    float inner = smoothstep(R, 0.0, r) * (1.0 - age);
    col += mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(0.0, R, r)) * (shell * (0.3 + fil * 1.6) + inner * fil * 0.6) * (1.0 - age * 0.8);
    // Core flash right after the explosion, then a dim remnant.
    float flash = exp(-age * 30.0);
    col += vec3(1.0) * gfx_flash(flash) * exp(-r * 6.0) * 1.5;
    col += GFX_ACCENT * exp(-r * 40.0) * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
