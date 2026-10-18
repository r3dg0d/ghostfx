// @id digital-glitch
// @name Digital Glitch
// @category glitch
// @description Sudden horizontal slices of the screen jump sideways in quantised steps, with a hint of colour separation.
// @tags glitch, digital, displacement, cyber
// @mode post
// @uses hash crt
// @flashing true
// @distorts true
// @param RATE float 0.3 0.0 1.0 How often glitches occur
// @param SHIFT float 0.04 0.0 0.2 Maximum slice displacement (fraction of width)
// @preset subtle RATE=0.12 SHIFT=0.015
// @preset cinematic RATE=0.6 SHIFT=0.08

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float tick = floor(t * 12.0);
    float burst = step(1.0 - P_RATE, hash11(floor(t * 2.0) * 3.7));
    float rows = 6.0 + floor(hash11(tick) * 30.0);
    float row = floor(uv.y * rows);
    float h = hash12(vec2(row, tick));
    // Between bursts a few rows still twitch slightly, so the effect never vanishes.
    float idle = (1.0 - burst) * step(0.97, h) * 0.15;
    float on = max(burst * step(0.75, h), idle) * GFX_DISTORT_TEXT;
    float shift = (floor(hash12(vec2(row, tick + 1.0)) * 8.0) / 8.0 - 0.5) * 2.0 * P_SHIFT * on * (0.4 + 0.6 * GFX_INTENSITY);
    vec2 suv = vec2(fract(uv.x + shift), uv.y);
    vec3 col = term_chroma(suv, vec2(0.003 * on + 0.0006 * GFX_INTENSITY, 0.0));
    col += on * gfx_flash(0.08) * vec3(0.3, 0.0, 0.4);
    fragColor = gfx_post_k(gfx_term(suv), col, 1.0);
}
