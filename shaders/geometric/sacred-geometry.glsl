// @id sacred-geometry
// @name Sacred Geometry
// @category geometric
// @description A golden Flower of Life with Metatron-style lines and slowly counter-rotating rings, drawn in fine glowing strokes.
// @tags geometry, sacred, mandala, gold, minimal, spiritual
// @mode background
// @uses sdf
// @color PRIMARY #E8C26A
// @color SECONDARY #08070A
// @color ACCENT #8E7BFF
// @param SIZE float 0.09 0.04 0.16 Circle radius

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.38, 0.0);
    float R = P_SIZE;
    float px = 1.5 * gfx_pxsize();
    float lines = 0.0;
    // Flower of Life: 19 circles on a hexagonal lattice.
    vec2 q = gfx_rot(t * 0.02) * c;
    for (int j = -2; j <= 2; j++)
    for (int i = -2; i <= 2; i++) {
        vec2 h = vec2(float(i) + 0.5 * float(j), float(j) * 0.8660254) * R;
        if (length(h) > R * 2.01) continue;
        lines += smoothstep(px, 0.0, abs(length(q - h) - R));
    }
    lines += smoothstep(px, 0.0, abs(length(c) - R * 3.0)) * 1.2;
    // Metatron lines: hexagram connecting the outer circle centres.
    vec2 r = gfx_rot(-t * 0.03) * c;
    for (int k = 0; k < 6; k++) {
        float a = float(k) * 1.0471976;
        vec2 a1 = vec2(cos(a), sin(a)) * R * 2.0;
        vec2 a2 = vec2(cos(a + 2.0944), sin(a + 2.0944)) * R * 2.0;
        lines += smoothstep(px, 0.0, sd_segment(r, a1, a2)) * 0.6;
    }
    // Outer counter-rotating dashed rings.
    float ang = atan(c.y, c.x);
    float ring1 = smoothstep(px, 0.0, abs(length(c) - R * 3.4)) * step(0.5, fract(ang / 6.2831 * 48.0 + t * 0.03));
    float ring2 = smoothstep(px, 0.0, abs(length(c) - R * 3.7)) * step(0.7, fract(ang / 6.2831 * 12.0 - t * 0.02));
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * min(lines, 1.5) * 0.8;
    col += GFX_ACCENT * (ring1 + ring2) * 0.6;
    col += GFX_PRIMARY * 0.06 * exp(-length(c) * 3.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
