// @id radiation-field
// @name Radiation Field
// @category experimental
// @description A sickly green radiation field: particles streak through the gloom in random tracks, with the click-like flashes of a Geiger counter.
// @tags radiation, geiger, green, particles, sci-fi
// @mode background
// @uses hash value
// @flashing true
// @color PRIMARY #9DFF3D
// @color SECONDARY #050A03
// @color ACCENT #E9FF9E
// @param ACTIVITY float 1.0 0.2 3.0 Decay events per second (relative)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * 0.06 * vnoise(p * 3.0 + t * 0.1);
    // Tracks: short straight segments that appear and fade (cloud-chamber style).
    for (int i = 0; i < 10; i++) {
        float fi = float(i);
        float rate = 0.7 * P_ACTIVITY;
        float slot = floor(t * rate + hash11(fi) * 10.0);
        float age = fract(t * rate + hash11(fi) * 10.0);
        vec2 a = (hash22(vec2(fi, slot)) - 0.5) * vec2(gfx_aspect(), 1.0);
        vec2 dir = normalize(hash22(vec2(slot, fi)) - 0.5);
        vec2 b = a + dir * (0.1 + 0.3 * hash11(slot + fi));
        vec2 pa = p - a, ba = b - a;
        float hh = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
        float d = length(pa - ba * hh);
        float drawn = step(hh, smoothstep(0.0, 0.15, age));
        col += GFX_PRIMARY * exp(-d * 500.0) * drawn * (1.0 - age) * 0.9;
    }
    // Geiger flash: brief brightening on random ticks.
    float tick = floor(t * 6.0 * P_ACTIVITY);
    float flash = step(0.82, hash11(tick)) * exp(-fract(t * 6.0 * P_ACTIVITY) * 6.0);
    col += GFX_ACCENT * gfx_flash(flash) * 0.08;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
