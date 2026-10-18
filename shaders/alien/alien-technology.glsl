// @id alien-technology
// @name Alien Technology
// @category alien
// @description Curving Truchet circuitry of unknown design, with violet and green pulses chasing each other through it.
// @tags alien, circuits, truchet, purple, green, tech
// @mode background
// @uses hash
// @color PRIMARY #B266FF
// @color SECONDARY #05030A
// @color ACCENT #4DFFB8
// @param SCALE float 12.0 5.0 30.0 Tiles per screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_SCALE;
    vec2 id = floor(g);
    vec2 f = fract(g) - 0.5;
    // Truchet tile: two quarter arcs, flipped per tile.
    if (hash12(id) > 0.5) f.x = -f.x;
    vec2 c1 = f - vec2(0.5, 0.5), c2 = f + vec2(0.5, 0.5);
    float d1 = abs(length(c1) - 0.5), d2 = abs(length(c2) - 0.5);
    float d = min(d1, d2);
    // Arc-length parameter for pulses that flow along the traces.
    float a = d1 < d2 ? atan(c1.y, c1.x) : atan(c2.y, c2.x);
    float s = a * 2.0 / 3.1416 + id.x + id.y;
    float pulse = pow(0.5 + 0.5 * sin(s * 3.1416 - t * 3.0), 12.0);
    float pulse2 = pow(0.5 + 0.5 * sin(s * 1.7 + t * 2.0 + 1.0), 16.0);

    float trace = smoothstep(0.06, 0.03, d);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * trace * 0.18;
    col += GFX_PRIMARY * trace * pulse * 1.1 + GFX_ACCENT * trace * pulse2 * 0.9;
    col += (GFX_PRIMARY * pulse + GFX_ACCENT * pulse2) * exp(-d * 18.0) * 0.12;
    // Nodes at tile corners.
    vec2 corner = abs(fract(g + 0.5) - 0.5);
    col += GFX_ACCENT * smoothstep(0.08, 0.05, length(corner)) * 0.35;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
