// @id alien-interface
// @name Alien Interface
// @category alien
// @description An extraterrestrial HUD: rotating segmented rings, scrolling glyph columns and a faint hex lattice in sickly green.
// @tags alien, hud, interface, sci-fi, green
// @mode background
// @uses hash sdf
// @color PRIMARY #7CFF9B
// @color SECONDARY #020A06
// @color ACCENT #00C2A8

float ring_segments(vec2 p, float r, float w, float segs, float rot, float fill) {
    float d = abs(length(p) - r) - w;
    float a = fract((atan(p.y, p.x) + rot) / 6.2831 * segs);
    return smoothstep(0.002, 0.0, d) * step(a, fill);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;

    // Hex lattice.
    vec2 h = p * 14.0;
    col += GFX_ACCENT * smoothstep(0.05, 0.0, 0.5 - hex_edge(hex_tile(h).xy)) * 0.08;

    // Rings around an off-centre focus.
    vec2 c = p - vec2(0.45 * gfx_aspect() * 0.5, 0.05);
    float rings = ring_segments(c, 0.30, 0.004, 24.0, t * 0.2, 0.7)
                + ring_segments(c, 0.34, 0.010, 7.0, -t * 0.13, 0.55)
                + ring_segments(c, 0.40, 0.002, 60.0, t * 0.05, 0.3)
                + ring_segments(c, 0.22, 0.015, 3.0, t * 0.4, 0.2);
    col += GFX_PRIMARY * rings * 0.7;
    col += GFX_PRIMARY * glow(abs(length(c) - 0.05), 0.003) * (0.5 + 0.5 * sin(t * 3.0));

    // Scrolling glyph columns on the far right.
    vec2 gq = (p - vec2(0.5 * gfx_aspect() - 0.22, 0.0)) * vec2(40.0, 40.0) + vec2(0.0, t * 3.0);
    if (gq.x > 0.0 && gq.x < 7.0) {
        vec2 id = floor(gq), f = fract(gq);
        float bits = step(0.5, hash12(id + floor(f * 3.0) * 0.37 + floor(t * 2.0) * 0.0));
        float on = step(0.3, hash12(vec2(id.y, 1.0))) * bits * step(0.15, f.x) * step(0.15, f.y);
        col += GFX_ACCENT * on * 0.35;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
