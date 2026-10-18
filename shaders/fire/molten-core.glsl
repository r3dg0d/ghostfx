// @id molten-core
// @name Molten Core
// @category fire
// @description Cracked black rock with a branching network of white-hot fissures that pulse with heat and shimmer the air.
// @tags molten, cracks, heat, distortion, red, rock
// @mode background
// @uses fbm
// @distorts true
// @color PRIMARY #FF2A00
// @color SECONDARY #0C0505
// @color ACCENT #FFE08A

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec2 q = p * 3.0;
    float r = ridged(q + vec2(0.0, 0.0));
    float cracks = pow(clamp(r * 1.1, 0.0, 1.0), 6.0);
    float pulse = 0.7 + 0.3 * sin(t * 1.2 - length(p) * 4.0);
    float rock = fbm(q * 3.0);

    vec3 col = GFX_SECONDARY * (0.5 + rock);
    col += mix(GFX_PRIMARY, GFX_ACCENT, cracks) * cracks * pulse * 1.6;
    col += GFX_PRIMARY * pow(r, 3.0) * 0.25 * pulse;

    // Heat shimmer strongest above hot cracks.
    vec2 shim = vec2(vnoise(vec2(p.x * 30.0, p.y * 20.0 - t * 4.0)) - 0.5, 0.0);
    vec2 off = shim * cracks * 3.0 * gfx_dpi() / iResolution.xy;
    vec4 term = gfx_term(uv + gfx_text_offset(off));
    fragColor = gfx_compose(uv, term, col);
}
