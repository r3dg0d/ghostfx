// @id signal-interference
// @name Signal Interference
// @category glitch
// @description Electronic interference: wavy horizontal distortion, tinted noise bars and brief signal dropouts.
// @tags glitch, interference, analog, noise, signal
// @mode post
// @uses hash value
// @flashing true
// @distorts true
// @param WAVE float 1.0 0.0 3.0 Horizontal wave distortion in pixels (x2)
// @param BARS float 0.6 0.0 1.0 Noise bar strength

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float wave = sin(uv.y * 60.0 + t * 8.0) * sin(uv.y * 7.0 - t * 1.3) * P_WAVE * 2.0 * gfx_dpi() / iResolution.x;
    vec2 suv = uv + vec2(wave * GFX_DISTORT_TEXT, 0.0);
    vec4 term = gfx_term(suv);
    vec3 col = gfx_straight(term);
    // Noise bars rolling upward, tinted.
    float bar = smoothstep(0.7, 1.0, vnoise(vec2(uv.y * 12.0 - t * 2.0, t * 0.5)));
    float n = hash12(fragCoord * 0.5 + floor(t * 30.0));
    col = mix(col, vec3(n) * vec3(0.7, 0.9, 1.0), bar * P_BARS * 0.5);
    // Dropout: brief dimming of random bands.
    float drop = step(0.97, hash12(vec2(floor(uv.y * 20.0), floor(t * 6.0))));
    col *= 1.0 - gfx_flash(drop * 0.5);
    fragColor = gfx_post(term, col);
}
