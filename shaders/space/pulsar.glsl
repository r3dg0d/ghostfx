// @id pulsar
// @name Pulsar
// @category space
// @description A spinning neutron star sweeps twin lighthouse beams across space inside a cage of magnetic field loops.
// @tags space, pulsar, beams, magnetic, blue
// @mode background
// @uses hash
// @flashing true
// @color PRIMARY #9FD3FF
// @color SECONDARY #02030A
// @color ACCENT #C88BFF
// @param SPIN float 0.6 0.1 3.0 Rotations per second

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.35, 0.0);
    float r = length(c);
    vec3 col = GFX_SECONDARY;
    vec2 g = p * 70.0;
    col += vec3(0.7) * step(0.988, hash12(floor(g))) * smoothstep(0.3, 0.0, length(fract(g) - 0.5));

    // Dipole field loops: r = L * cos^2(latitude), drawn for several L.
    vec2 m = gfx_rot(0.35) * c;
    float lat = atan(m.x, m.y);
    float cl = cos(lat);
    float L = r / max(cl * cl, 1e-3);
    float loops = 0.0;
    for (int i = 1; i <= 4; i++) {
        float Li = 0.1 * float(i);
        loops += smoothstep(0.006, 0.0, abs(L - Li) * cl * cl);
    }
    col += GFX_ACCENT * loops * 0.25 * smoothstep(0.02, 0.05, r);

    // Twin beams rotating about the tilted axis.
    float ang = t * P_SPIN * 6.2831;
    vec2 bd = vec2(cos(ang), sin(ang));
    float across = abs(dot(c, vec2(-bd.y, bd.x)));
    float beam = exp(-across / (0.01 + r * 0.08)) * smoothstep(0.0, 0.05, r);
    col += GFX_PRIMARY * beam * 0.7;
    // Pulse when a beam points at the viewer (modelled as crossing horizontal).
    float pulse = pow(abs(cos(ang)), 30.0);
    col += GFX_PRIMARY * exp(-r * 25.0) * (0.6 + gfx_flash(pulse) * 1.2);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
