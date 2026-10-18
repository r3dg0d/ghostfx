// @id alien-radar
// @name Alien Radar
// @category alien
// @description A hexagonal scope with three rotating sweeps, leaving fading trails and blips of unknown contacts.
// @tags radar, alien, hexagon, sweep, green
// @mode background
// @uses hash sdf
// @color PRIMARY #7DFF6A
// @color SECONDARY #020802
// @color ACCENT #FF4FA3
// @param RADIUS float 0.36 0.2 0.5 Scope size

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(-0.5 * gfx_aspect() + P_RADIUS + 0.06, 0.0);
    float R = P_RADIUS;
    float hex = sd_hexagon(gfx_rot(0.5236) * c, R * 0.87);
    vec3 col = GFX_SECONDARY;
    if (hex < 0.0) {
        float r = length(c);
        float a = atan(c.y, c.x);
        float trail = 0.0;
        for (int i = 0; i < 3; i++) {
            float fi = float(i);
            float sweep = mod(t * (0.8 + 0.25 * fi) + fi * 2.094, 6.2831);
            float da = mod(sweep - a, 6.2831);
            trail = max(trail, exp(-da * 3.0));
        }
        col += GFX_PRIMARY * trail * 0.35;
        // Concentric hex rings and spokes.
        float rings = smoothstep(0.004, 0.0, abs(fract(hex / (R * 0.2)) - 0.5) * R * 0.2 - 0.0);
        col += GFX_PRIMARY * (0.12 * smoothstep(0.003, 0.0, abs(mod(-hex, R * 0.2) - R * 0.1) - R * 0.098));
        float spoke = smoothstep(0.003, 0.0, abs(sin(a * 3.0)) * r);
        col += GFX_PRIMARY * spoke * 0.1;
        // Contacts light up when a sweep passes.
        for (int k = 0; k < 7; k++) {
            float fk = float(k);
            vec2 bp = (hash22(vec2(fk, floor(t * 0.05))) - 0.5) * R * 1.4;
            bp += 0.02 * vec2(sin(t * 0.3 + fk), cos(t * 0.2 + fk));
            float ba = atan(bp.y, bp.x);
            float lit = 0.0;
            for (int i = 0; i < 3; i++) {
                float fi = float(i);
                float sweep = mod(t * (0.8 + 0.25 * fi) + fi * 2.094, 6.2831);
                lit = max(lit, exp(-mod(sweep - ba, 6.2831) * 1.5));
            }
            vec3 bc = mix(GFX_PRIMARY, GFX_ACCENT, step(0.7, hash11(fk)));
            col += bc * smoothstep(0.012, 0.0, length(c - bp)) * lit * 1.5;
        }
    }
    col += GFX_PRIMARY * smoothstep(0.004, 0.0, abs(hex)) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
