// @id ufo-energy
// @name UFO Energy
// @category alien
// @description A tractor beam pours down from above, rings of energy pulsing along it inside a shimmering haze.
// @tags ufo, beam, energy, alien, green, glow
// @mode background
// @uses value
// @color PRIMARY #66FF8C
// @color SECONDARY #03060A
// @color ACCENT #E2FFE8
// @param X float 0.0 -0.8 0.8 Beam position

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = p - vec2(P_X, 0.55);
    float y = -q.y;                           // distance down from the craft
    float halfw = 0.04 + y * 0.32;            // cone widens toward the ground
    float inside = smoothstep(halfw, halfw * 0.8, abs(q.x));
    float edge = exp(-abs(abs(q.x) - halfw) * 60.0) * step(0.0, y);

    vec3 col = GFX_SECONDARY;
    float haze = vnoise(vec2(q.x * 10.0, y * 6.0 - t * 2.0));
    col += GFX_PRIMARY * inside * (0.12 + 0.12 * haze) * step(0.0, y);
    // Pulsing rings travelling down the beam.
    float rings = pow(0.5 + 0.5 * sin(y * 25.0 - t * 5.0), 8.0);
    col += GFX_PRIMARY * inside * rings * 0.35;
    col += GFX_ACCENT * edge * 0.4;
    // The craft's underside glow.
    col += GFX_ACCENT * 0.5 * exp(-length(q * vec2(1.0, 4.0)) * 12.0);
    // Ground pool.
    col += GFX_PRIMARY * 0.25 * exp(-length(vec2(q.x * 0.6, p.y + 0.5)) * 5.0) * (0.8 + 0.2 * sin(t * 3.0));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
