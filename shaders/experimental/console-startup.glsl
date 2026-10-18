// @id console-startup
// @name Console Startup
// @category experimental
// @description A retro games-console boot: a chrome emblem drops in, flashes once, and shimmers before settling into the background.
// @tags console, startup, retro, boot, logo, 90s
// @mode background
// @uses sdf
// @flashing true
// @color PRIMARY #B8C4FF
// @color SECONDARY #05060C
// @color ACCENT #FF5C8A
// @param CYCLE float 12.0 4.0 60.0 Seconds between startup sequences

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = mod(t, P_CYCLE);
    // Drop with a small bounce, then flash, then shimmer.
    float fall = k < 0.8 ? 1.0 - pow(1.0 - k / 0.8, 3.0) : 1.0;
    float bounce = k < 0.8 ? 0.0 : 0.03 * exp(-(k - 0.8) * 6.0) * sin((k - 0.8) * 20.0);
    vec2 c = p - vec2(0.42, mix(0.7, 0.05, fall) + bounce);
    // A generic emblem: a diamond inside a ring with a bar through it.
    float diamond = abs(c.x) + abs(c.y) - 0.09;
    float ring = abs(length(c) - 0.14) - 0.012;
    float bar = sd_box(c, vec2(0.2, 0.012));
    float d = min(min(diamond, ring), bar);
    float shape = smoothstep(0.003, -0.003, d);
    float sheen = smoothstep(0.03, 0.0, abs(c.x + c.y - mod(k * 0.5, 1.5) + 0.75));
    vec3 col = GFX_SECONDARY;
    col += mix(GFX_PRIMARY * 0.6, vec3(1.0), sheen) * shape;
    col += GFX_ACCENT * smoothstep(0.003, -0.003, diamond) * 0.6;
    float flash = exp(-max(k - 0.85, 0.0) * 8.0) * step(0.85, k);
    col += vec3(1.0) * gfx_flash(flash) * exp(-length(c) * 4.0) * 0.8;
    col *= 1.0 - smoothstep(4.0, 5.0, k) * 0.7;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
