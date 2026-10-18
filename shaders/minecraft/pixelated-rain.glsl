// @id pixelated-rain
// @name Pixelated Rain
// @category minecraft
// @description Chunky retro raindrops fall in pixel columns from blocky clouds and splash into tiny pixel bursts at the bottom.
// @tags rain, pixel, retro, blue, weather, minecraft-inspired
// @mode background
// @uses hash
// @inspired Minecraft's blocky weather (original procedural interpretation, no game assets)
// @color PRIMARY #6E9BFF
// @color SECONDARY #10141E
// @color ACCENT #3A4A66
// @param PIXELS float 120.0 50.0 260.0 Pixel rows across the screen height

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = floor(p * P_PIXELS);

    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.6, smoothstep(-0.5, 0.5, p.y));
    // Blocky clouds along the top.
    float cl = hash12(vec2(floor(c.x / 8.0 + t * 0.5), 0.0));
    if (p.y > 0.42 - 0.04 * cl) col = GFX_ACCENT * (0.7 + 0.2 * cl);

    // Drops: one per column, 1 px wide, 4 px long.
    float h = hash11(c.x * 0.137);
    float speed = 55.0 + 30.0 * h;
    float headY = P_PIXELS * 0.45 - mod(t * speed + h * 300.0, P_PIXELS * 1.2);
    float dy = c.y - headY;
    if (h < 0.55 && dy >= 0.0 && dy < 4.0) col = GFX_PRIMARY * (1.0 - dy * 0.15);

    // Splashes: pixels kicked up where each drop lands.
    float ground = -P_PIXELS * 0.5 + 2.0;
    float landT = fract((t * speed + h * 300.0) / (P_PIXELS * 1.2));
    float sp = smoothstep(0.88, 0.93, landT) * (1.0 - smoothstep(0.93, 1.0, landT));
    vec2 rel = c - vec2(c.x, ground);
    if (h < 0.55 && sp > 0.0 && rel.y > 0.0 && rel.y < 3.0) col += GFX_PRIMARY * 0.5 * sp;
    float side = hash11(floor((c.x - 1.0)) * 0.137);
    if (side < 0.55 && c.y - ground > 0.0 && c.y - ground < 2.0 && sp > 0.0) col += GFX_PRIMARY * 0.3 * sp;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
