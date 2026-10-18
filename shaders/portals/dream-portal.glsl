// @id dream-portal
// @name Dream Portal
// @category portals
// @description A soft arched doorway opens onto pastel clouds, with bubbles drifting out into a hazy lilac evening.
// @tags dream, portal, pastel, soft, surreal, calm
// @mode background
// @uses fbm sdf hash
// @color PRIMARY #FFC6E8
// @color SECONDARY #2A2140
// @color ACCENT #A8E6FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_SECONDARY * 1.6 + GFX_PRIMARY * 0.08, smoothstep(-0.5, 0.5, p.y));
    // Arched doorway: a box topped with a half circle.
    vec2 a = p - vec2(0.42, -0.08);
    float arch = min(sd_box(a + vec2(0.0, 0.1), vec2(0.14, 0.24)), length(a - vec2(0.0, 0.14)) - 0.14);
    float inside = smoothstep(0.004, -0.004, arch);
    vec2 q = a * 3.0 + vec2(t * 0.04, 0.0);
    float cl = fbm(q + 0.5 * fbm(q * 2.0 - t * 0.03));
    vec3 dream = mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(0.3, 0.7, cl + a.y));
    dream = mix(dream, vec3(1.0), smoothstep(0.6, 0.85, cl) * 0.6);
    col = mix(col, dream * 0.9, inside);
    col += mix(GFX_PRIMARY, GFX_ACCENT, 0.5) * exp(-abs(arch) * 60.0) * 0.4;
    col += GFX_PRIMARY * 0.12 * exp(-max(arch, 0.0) * 8.0) * (1.0 - inside);
    // Bubbles floating out of the door.
    for (int i = 0; i < 9; i++) {
        float fi = float(i);
        float life = fract(t * 0.05 + hash11(fi));
        vec2 b = vec2(0.42 + (hash11(fi * 2.3) - 0.5) * 0.25 - life * (0.3 + 0.6 * hash11(fi + 5.0)), -0.1 + life * 0.55 + 0.03 * sin(t + fi));
        float r = 0.008 + 0.018 * hash11(fi + 9.0);
        float d = length(p - b);
        float ring = smoothstep(0.004, 0.0, abs(d - r)) + smoothstep(r * 0.5, 0.0, length(p - b - vec2(-0.3, 0.3) * r)) * 0.6;
        col += mix(GFX_ACCENT, GFX_PRIMARY, hash11(fi)) * ring * sin(life * 3.1416) * 0.7;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
