// @id electric-arcs
// @name Electric Arcs
// @category electric
// @description Crackling arcs leap between pairs of electrodes, each discharge a jittering bundle of hot filaments.
// @tags electric, arcs, crackle, blue, energy
// @mode background
// @uses gradient hash sdf
// @flashing true
// @color PRIMARY #9EC9FF
// @color SECONDARY #03050C
// @color ACCENT #E8F4FF
// @param PAIRS int 3 1 6 Number of electrode pairs

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    float tick = floor(t * 18.0);
    for (int i = 0; i < P_PAIRS; i++) {
        float fi = float(i);
        float y = (fi + 0.5) / float(P_PAIRS) - 0.5;
        vec2 a = vec2(-0.5 * gfx_aspect() + 0.08, y * 0.9);
        vec2 b = vec2(0.5 * gfx_aspect() - 0.08, y * 0.9 + 0.1 * sin(t * 0.3 + fi));
        vec2 ab = b - a;
        float s = clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0);
        vec2 n = normalize(vec2(-ab.y, ab.x));
        float env = sin(s * 3.1416);
        float on = step(0.25, hash11(tick * 0.37 + fi));
        for (int k = 0; k < 3; k++) {
            float fk = float(k);
            float off = (gnoise(vec2(s * 8.0, tick + fk * 10.0 + fi * 5.0)) * 0.12 + gnoise(vec2(s * 30.0, tick * 1.3 + fk)) * 0.03) * env;
            vec2 q = a + ab * s + n * off;
            float d = length(p - q);
            col += mix(GFX_PRIMARY, GFX_ACCENT, 1.0 - fk / 3.0) * (smoothstep(0.003, 0.0, d) + glow(d, 0.004) * 0.25) * on * (1.0 - fk * 0.25);
        }
        col += GFX_PRIMARY * (glow(length(p - a), 0.012) + glow(length(p - b), 0.012)) * 0.6;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
