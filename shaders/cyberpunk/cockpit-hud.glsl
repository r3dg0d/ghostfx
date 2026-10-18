// @id cockpit-hud
// @name Cockpit HUD
// @category cyberpunk
// @description A fighter-jet heads-up display: a pitch ladder that banks gently, heading tape, and speed and altitude ladders, in clean green.
// @tags hud, cockpit, aviation, green, interface
// @mode background
// @uses sdf hash
// @color PRIMARY #5CFF8A
// @color SECONDARY #020604
// @color ACCENT #FFE45C

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float px = 1.5 * gfx_pxsize();
    vec3 col = GFX_SECONDARY;
    vec2 c = p - vec2(0.42, 0.0);
    float roll = 0.15 * sin(t * 0.2);
    float pitch = 0.08 * sin(t * 0.13);
    vec2 q = gfx_rot(roll) * c + vec2(0.0, pitch);
    float lines = 0.0;
    // Pitch ladder: rungs every 0.08 with a gap in the middle; horizon solid.
    float rung = q.y / 0.08;
    float fr = abs(fract(rung + 0.5) - 0.5) * 0.08;
    float isH = step(abs(q.y), 0.08 * 0.5);
    float w = mix(0.07, 0.25, isH);
    lines += smoothstep(px, 0.0, fr) * step(abs(q.x), w) * step(0.03, abs(q.x)) * step(abs(q.y), 0.3);
    // Boresight cross.
    lines += smoothstep(px, 0.0, abs(c.y)) * step(abs(c.x), 0.02) + smoothstep(px, 0.0, abs(c.x)) * step(abs(c.y), 0.02) * step(0.006, abs(c.y));
    // Speed (left) and altitude (right) ladders with scrolling ticks.
    for (int s = 0; s < 2; s++) {
        float side = s == 0 ? -1.0 : 1.0;
        float x = c.x - side * 0.3;
        float scroll = t * (s == 0 ? 0.05 : -0.03);
        float tick = smoothstep(px, 0.0, abs(fract(c.y * 12.5 + scroll) - 0.5) * 0.08 - 0.0) * step(abs(x), 0.012) * step(abs(c.y), 0.25);
        lines += tick;
        lines += smoothstep(px, 0.0, abs(x - side * 0.012)) * step(abs(c.y), 0.25);
    }
    // Heading tape along the top.
    float hd = (c.x * 20.0 + t * 0.3);
    lines += smoothstep(0.42, 0.48, abs(fract(hd) - 0.5)) * step(abs(c.y - 0.33), 0.012) * step(abs(c.x), 0.25);
    col += GFX_PRIMARY * min(lines, 1.0) * 0.85;
    col += GFX_ACCENT * smoothstep(0.004, 0.0, abs(length(c - vec2(0.05 * sin(t * 0.4), 0.03 * cos(t * 0.3))) - 0.015)) * 0.7;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
