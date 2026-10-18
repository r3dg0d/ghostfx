// @id retro-radar
// @name Retro Radar
// @category crt
// @description A round P7 radar scope: a green sweep paints contacts that linger and fade with long phosphor persistence.
// @tags radar, phosphor, green, retro, sweep, crt
// @mode background
// @uses hash
// @color PRIMARY #66FF7A
// @color SECONDARY #010501
// @color ACCENT #E0FFB8
// @param PERIOD float 4.0 1.0 12.0 Seconds per sweep revolution
// @limitation Persistence is computed from the sweep angle, since Ghostty provides no previous frame.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.5 * gfx_aspect() - 0.42, 0.0);
    float r = length(c);
    float R = 0.4;
    vec3 col = GFX_SECONDARY;
    if (r < R) {
        float sweep = mod(t / P_PERIOD * 6.2831, 6.2831);
        float a = mod(atan(c.y, c.x), 6.2831);
        float behind = mod(sweep - a, 6.2831);          // radians since the sweep passed
        float persist = exp(-behind * 0.9);
        col += GFX_PRIMARY * persist * 0.18;
        col += GFX_ACCENT * smoothstep(0.03, 0.0, behind) * 0.6;
        // Range rings and bearing lines.
        float rings = smoothstep(0.003, 0.0, abs(fract(r / R * 4.0 + 0.5) - 0.5) * R / 4.0);
        float spokes = smoothstep(0.002, 0.0, abs(sin(a * 6.0)) * r);
        col += GFX_PRIMARY * (rings + spokes) * 0.12;
        // Contacts: brighten when swept, then decay with the same persistence.
        for (int k = 0; k < 8; k++) {
            float fk = float(k);
            vec2 bp = (hash22(vec2(fk, floor(t / (P_PERIOD * 6.0)))) - 0.5) * R * 1.4;
            bp += 0.01 * vec2(sin(t * 0.1 + fk), cos(t * 0.13 + fk));
            float ba = mod(atan(bp.y, bp.x), 6.2831);
            float bb = mod(sweep - ba, 6.2831);
            col += GFX_ACCENT * smoothstep(0.01, 0.0, length(c - bp)) * exp(-bb * 0.6) * 1.2;
        }
    }
    col += GFX_PRIMARY * smoothstep(0.004, 0.0, abs(r - R)) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
