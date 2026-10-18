// @id extraterrestrial-signal
// @name Extraterrestrial Signal
// @category alien
// @description A radio telescope readout of a strange transmission: glowing waveform traces over a scrolling spectrogram.
// @tags alien, signal, radio, waveform, spectrogram, science
// @mode background
// @uses hash value sdf
// @color PRIMARY #57E1FF
// @color SECONDARY #02060B
// @color ACCENT #FF5FA2

float signal(float x, float t, float ch) {
    float s = sin(x * 9.0 + t * 2.0 + ch) * 0.5;
    s += sin(x * 23.0 * (1.0 + 0.1 * ch) - t * 3.0) * 0.25 * sin(t * 0.7 + ch);
    s += (vnoise(vec2(x * 60.0 + t * 8.0, ch)) - 0.5) * 0.35;
    // Bursts: the "message".
    s *= 0.6 + 0.8 * step(0.6, vnoise(vec2(x * 4.0 - t * 1.5, ch * 3.0)));
    return s;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;

    // Spectrogram waterfall in the lower third: frequency on x, time on y.
    if (uv.y < 0.33) {
        vec2 sp = vec2(uv.x * 64.0, uv.y * 40.0 + t * 6.0);
        float e = vnoise(vec2(floor(sp.x), floor(sp.y) * 0.3)) * vnoise(vec2(floor(sp.x) * 0.2, floor(sp.y) * 0.05));
        float line = step(0.97, hash11(floor(sp.x))) * 0.5;
        col += mix(GFX_PRIMARY * 0.4, GFX_ACCENT, e) * (pow(e, 2.0) * 0.6 + line * e);
    }
    // Three waveform traces.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float base = 0.05 + fi * 0.13;
        float y = base + signal(p.x, t, fi) * 0.05;
        float d = abs(p.y - y);
        col += mix(GFX_PRIMARY, GFX_ACCENT, fi * 0.5) * (smoothstep(0.003, 0.0, d) * 0.7 + glow(d, 0.004) * 0.15);
    }
    // Grid.
    vec2 gr = abs(fract(p * vec2(10.0, 10.0)) - 0.5);
    col += GFX_PRIMARY * smoothstep(0.49, 0.5, max(gr.x, gr.y)) * 0.05;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
