// @id tesla-coil
// @name Tesla Coil
// @category electric
// @description A Tesla coil's toroid throws branching purple-white streamers into the air in a constant buzzing crackle.
// @tags tesla, electric, streamers, purple, science
// @mode background
// @uses gradient hash sdf
// @flashing true
// @color PRIMARY #C9A6FF
// @color SECONDARY #04030A
// @color ACCENT #FFFFFF
// @param STREAMERS int 7 2 14 Simultaneous streamers

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 top = vec2(0.0, -0.32);
    vec3 col = GFX_SECONDARY;
    // Coil body and toroid.
    col += vec3(0.15, 0.1, 0.06) * smoothstep(0.004, 0.0, sd_box(p - vec2(0.0, -0.44), vec2(0.03, 0.1)));
    float tor = sd_box(p - top, vec2(0.09, 0.012)) - 0.012;
    col = mix(col, vec3(0.5, 0.5, 0.55), smoothstep(0.003, 0.0, tor));

    float tick = floor(t * (GFX_REDUCED_FLASH > 0.5 ? 2.5 : 14.0));
    for (int i = 0; i < P_STREAMERS; i++) {
        float fi = float(i);
        float h = hash11(tick * 0.13 + fi * 7.1);
        float ang = 3.1416 * (0.1 + 0.8 * hash11(fi * 3.3 + tick * 0.07));
        vec2 dir = vec2(cos(ang), sin(ang));
        float len = 0.25 + 0.4 * h;
        vec2 rel = p - top;
        float s = clamp(dot(rel, dir) / len, 0.0, 1.0);
        vec2 nrm = vec2(-dir.y, dir.x);
        float off = (gnoise(vec2(s * 6.0, tick + fi * 9.0)) * 0.12 + gnoise(vec2(s * 25.0, tick * 2.0 + fi)) * 0.03) * s;
        // Fork near the tip.
        float fork = step(0.6, s) * (s - 0.6) * (hash11(fi + tick) - 0.5) * 0.5;
        float d = min(abs(dot(rel, nrm) - off), abs(dot(rel, nrm) - off - fork));
        float alongOk = step(0.0, dot(rel, dir)) * step(dot(rel, dir), len);
        float w = 0.002 + 0.004 * (1.0 - s);
        col += mix(GFX_ACCENT, GFX_PRIMARY, s) * (smoothstep(w, 0.0, d) + glow(d, 0.005) * 0.3) * alongOk * (1.0 - s * 0.6);
    }
    col += GFX_PRIMARY * 0.25 * exp(-length(p - top) * 6.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
