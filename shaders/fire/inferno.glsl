// @id inferno
// @name Inferno
// @category fire
// @description A firestorm vortex: spiralling arms of flame converge on a blinding core at the centre of the screen.
// @tags fire, vortex, spiral, intense, orange
// @mode background
// @uses fbm
// @color PRIMARY #8A1300
// @color SECONDARY #FF6A00
// @color ACCENT #FFF3C4
// @param ARMS float 3.0 1.0 6.0 Spiral arms
// @param TWIST float 2.5 0.5 5.0 Spiral tightness

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float r = length(p);
    float a = atan(p.y, p.x);
    float spiral = a * P_ARMS / 6.2831 + log(r + 0.02) * P_TWIST * 0.5 + t * 0.35;
    // Noise is sampled in swirled Cartesian space (no atan() seam).
    vec2 q = gfx_rot(log(r + 0.02) * P_TWIST * 0.5 + t * 0.35) * p * 4.0 + vec2(0.0, -t * 0.8);
    float n = fbm(q + fbm(q * 1.5 + t * 0.2));
    float arms = 0.5 + 0.5 * sin(spiral * 6.2831);
    float heat = n * (0.6 + 0.6 * arms) * (1.2 - r * 0.9) + 0.35 * exp(-r * 6.0);
    heat = clamp(heat, 0.0, 1.2);

    vec3 col = mix(vec3(0.02, 0.0, 0.0), GFX_PRIMARY, smoothstep(0.1, 0.4, heat));
    col = mix(col, GFX_SECONDARY, smoothstep(0.4, 0.75, heat));
    col = mix(col, GFX_ACCENT, smoothstep(0.8, 1.15, heat));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
