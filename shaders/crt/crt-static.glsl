// @id crt-static
// @name CRT Static
// @category crt
// @description A weak analog signal: crawling snow, faint diagonal interference and a picture that fades in and out of the noise.
// @tags crt, static, noise, analog, retro
// @mode post
// @uses crt hash value
// @flashing true
// @param SNOW float 0.18 0.0 0.6 Snow strength
// @param INTERFERENCE float 0.5 0.0 1.0 Diagonal interference strength
// @preset subtle SNOW=0.08 INTERFERENCE=0.2

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(term);
    float sig = 0.85 + 0.15 * vnoise(vec2(t * 0.7, 0.0));
    vec2 cell = floor(fragCoord / max(gfx_dpi() * 1.5, 1.0));
    float snow = hash12(cell + floor(t * 40.0) * vec2(13.1, 7.7));
    float rate = GFX_REDUCED_FLASH > 0.5 ? 0.2 : 1.0;
    float diag = sin((fragCoord.x + fragCoord.y * 1.7) * 0.15 / gfx_dpi() - t * 20.0 * rate) * 0.5 + 0.5;
    col = col * sig + (snow - 0.5) * P_SNOW * gfx_flash(1.0) * 1.4;
    col += vec3(0.6, 0.65, 0.7) * diag * P_INTERFERENCE * 0.05;
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.25);
    col *= vignette(uv, 0.35);
    fragColor = gfx_post(term, col);
}
