// @id experience-orbs
// @name Experience Orbs
// @category minecraft
// @description Bobbing pixel orbs shimmer between lime and gold, drifting together like they are being collected.
// @tags orbs, green, pixel, glow, minecraft-inspired
// @mode background
// @uses hash
// @inspired Minecraft experience orbs (original procedural interpretation, no game assets)
// @color PRIMARY #9DFF2E
// @color SECONDARY #050A04
// @color ACCENT #F5E22B
// @param COUNT int 22 6 50 Number of orbs

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float PX = 110.0;
    vec2 q = (floor(p * PX) + 0.5) / PX;
    vec3 col = GFX_SECONDARY;

    for (int i = 0; i < P_COUNT; i++) {
        float fi = float(i);
        vec2 h = hash22(vec2(fi, 2.0));
        vec2 home = (h - 0.5) * vec2(gfx_aspect(), 1.0) * 0.9;
        // Orbs slowly gather toward the centre, then scatter again.
        float pull = 0.5 - 0.5 * cos(t * 0.15 + h.x * 0.5);
        vec2 pos = mix(home, home * 0.25, pull);
        pos.y += 0.02 * sin(t * 2.0 + fi);
        vec2 d = (q - pos) * PX;
        float sz = 2.5 + 2.0 * hash11(fi * 5.0);
        // Octagonal pixel blob.
        float shape = step(abs(d.x) + abs(d.y), sz * 1.4) * step(max(abs(d.x), abs(d.y)), sz);
        float hi = step(abs(d.x + sz * 0.35) + abs(d.y - sz * 0.35), sz * 0.5);
        float shimmer = 0.5 + 0.5 * sin(t * 4.0 + fi * 1.3);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, shimmer);
        col = mix(col, c * (0.75 + 0.5 * hi), shape);
        col += c * 0.04 / (1.0 + dot(d, d) * 0.02);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
