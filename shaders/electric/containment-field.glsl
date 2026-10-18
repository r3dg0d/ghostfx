// @id containment-field
// @name Containment Field
// @category electric
// @description A writhing ball of energy held inside a cage of glowing field rings that tighten and flex whenever it pushes outward.
// @tags containment, field, energy, rings, sci-fi, plasma
// @mode background
// @uses fbm
// @color PRIMARY #5CF2FF
// @color SECONDARY #020509
// @color ACCENT #FF6BE0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.42, 0.0);
    float r = length(c);
    vec2 sw = gfx_rot(t * 0.6) * c;
    float push = 0.5 + 0.5 * sin(t * 0.9);
    float blob = fbm(sw * 8.0 + t * 0.5);
    float R = 0.11 + 0.03 * push + 0.03 * (blob - 0.5);
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_ACCENT, vec3(1.0), blob) * smoothstep(R, R * 0.6, r) * (0.6 + 0.6 * blob);
    col += GFX_ACCENT * exp(-max(r - R, 0.0) * 20.0) * 0.3;
    // Cage: vertical field rings (ellipses) flexing outward with the push.
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float ph = fi / 5.0 * 3.1416 + t * 0.4;
        float wx = 0.2 * abs(cos(ph)) + 0.01;
        vec2 q = c / vec2(wx * (1.0 + 0.1 * push), 0.2 + 0.02 * push);
        float d = abs(length(q) - 1.0) * wx;
        float front = sin(ph) > 0.0 ? 1.0 : 0.4;
        col += GFX_PRIMARY * (smoothstep(0.003, 0.0, d) + exp(-d * 200.0) * 0.2) * front;
    }
    col += GFX_PRIMARY * smoothstep(0.004, 0.0, abs(abs(c.y) - 0.21)) * step(abs(c.x), 0.22) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
