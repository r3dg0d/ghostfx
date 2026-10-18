// @id dna-helix
// @name DNA Helix
// @category experimental
// @description A double helix rotates across the screen, its two backbones winding around coloured base-pair rungs.
// @tags dna, helix, biology, science, rotating
// @mode background
// @uses hash
// @color PRIMARY #4DD9FF
// @color SECONDARY #04060C
// @color ACCENT #FF5FA8

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Helix axis runs along x, slightly tilted, centred low on the screen.
    vec2 q = gfx_rot(-0.15) * (p - vec2(0.0, -0.25));
    float ph = q.x * 9.0 - t * 0.8;
    float R = 0.08;
    float y1 = R * sin(ph), y2 = R * sin(ph + 3.1416);
    float z1 = cos(ph);                         // depth for shading/occlusion
    float px = 2.0 * gfx_pxsize();
    float s1 = smoothstep(0.012, 0.004, abs(q.y - y1)) * (0.55 + 0.45 * z1);
    float s2 = smoothstep(0.012, 0.004, abs(q.y - y2)) * (0.55 - 0.45 * z1);
    // Rungs every quarter turn, coloured by base pair.
    float rungId = floor(ph / 0.6283);
    float rung = smoothstep(0.08, 0.02, abs(fract(ph / 0.6283) - 0.5)) * step(abs(q.y), abs(y1) + px);
    vec3 rc = mix(GFX_ACCENT, vec3(1.0, 0.85, 0.3), step(0.5, hash11(rungId))) * (0.4 + 0.3 * abs(z1));
    col += rc * rung * 0.8;
    col += GFX_PRIMARY * max(s1, s2) * 1.1;
    col += GFX_PRIMARY * 0.08 * exp(-abs(q.y) * 12.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
