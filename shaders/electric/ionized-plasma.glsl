// @id ionized-plasma
// @name Ionized Plasma
// @category electric
// @description Glowing ionised gas churns in teal and magenta, threaded with crackling discharge filaments.
// @tags plasma, ionized, energy, teal, magenta
// @mode background
// @uses fbm
// @color PRIMARY #19E3C8
// @color SECONDARY #030409
// @color ACCENT #FF3DC8

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.5;
    float t = gfx_time();
    vec2 q;
    float gas = warped_fbm(p, t * 0.5, q);
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_PRIMARY, GFX_ACCENT, q.x) * pow(gas, 2.0) * 0.8;
    // Discharges follow ridges of the warped field and flicker.
    float fil = pow(ridged(p * 2.0 + q * 3.0 + t * 0.4), 12.0);
    float flick = 0.6 + 0.4 * sin(t * 17.0 + q.y * 20.0);
    col += mix(vec3(1.0), GFX_ACCENT, 0.3) * fil * flick * 1.2;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
