// @id nether-portal
// @name Nether Portal
// @category minecraft
// @description A swirling sheet of violet dimensional energy rendered in chunky pixels, framed by obsidian blocks.
// @tags portal, purple, pixel, swirl, minecraft-inspired
// @mode background
// @uses fbm hash
// @inspired Minecraft's nether portal (original procedural interpretation, no game assets)
// @color PRIMARY #7B1FE0
// @color SECONDARY #1A0433
// @color ACCENT #E7B8FF
// @param PIXELS float 90.0 30.0 240.0 Pixel rows across the screen height
// @param FRAME float 1.0 0.0 1.0 Draw the obsidian frame

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec2 q = (floor(p * P_PIXELS) + 0.5) / P_PIXELS;
    float r = length(q);
    float a = atan(q.y, q.x);
    vec2 w = vec2(q.x * 3.0 + 0.4 * sin(q.y * 6.0 + t), q.y * 2.0 - t * 0.25);
    w += 0.5 * vec2(fbm(w + t * 0.15), fbm(w * 1.3 - t * 0.1));
    float n = fbm(w * 1.6 + vec2(q.y * 0.3, r));
    float streak = 0.5 + 0.5 * sin(q.x * 25.0 + n * 9.0 + t * 1.5);
    float v = n * 0.75 + streak * 0.35;
    v = floor(v * 6.0) / 6.0;   // quantised palette, like a 16px texture

    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, smoothstep(0.2, 0.7, v));
    col = mix(col, GFX_ACCENT, smoothstep(0.75, 1.0, v));

    // Obsidian frame made of two-pixel blocks with a faint purple sheen.
    vec2 half_ = vec2(0.5 * gfx_aspect(), 0.5);
    vec2 e = half_ - abs(q);
    float edge = min(e.x, e.y);
    if (P_FRAME > 0.5 && edge < 0.045) {
        vec2 b = floor(q * P_PIXELS / 6.0);
        float s = hash12(b);
        col = vec3(0.03, 0.02, 0.06) + vec3(0.12, 0.05, 0.2) * step(0.8, hash12(floor(q * P_PIXELS))) * s;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
