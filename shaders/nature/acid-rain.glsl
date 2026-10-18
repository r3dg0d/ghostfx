// @id acid-rain
// @name Acid Rain
// @category nature
// @description Toxic green rain hisses down through a polluted haze, each drop leaving a short corroding drip where it lands.
// @tags rain, acid, toxic, green, dystopian
// @mode background
// @uses hash fbm
// @color PRIMARY #B8FF3D
// @color SECONDARY #070A04
// @color ACCENT #4F6B1F

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float haze = fbm(vec2(p.x * 1.5 + t * 0.03, p.y * 2.0 - t * 0.02));
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.45, haze * smoothstep(-0.6, 0.5, p.y));
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = vec2((p.x - p.y * 0.12) * (70.0 + fi * 40.0), p.y * 3.0 + t * (6.0 + fi * 2.0)) + fi * 17.0;
        vec2 id = floor(q);
        float on = step(0.9, hash12(id));
        float streak = on * smoothstep(0.3, 0.0, abs(fract(q.x) - 0.5)) * smoothstep(0.0, 0.6, fract(q.y));
        col += GFX_PRIMARY * streak * (0.45 - fi * 0.1);
    }
    // Drips: hanging beads that slowly stretch from the top edge.
    float cx = floor(p.x * 30.0);
    float h = hash11(cx * 3.1);
    float len = fract(t * 0.05 * (0.5 + h) + h) * 0.25 * step(0.6, h);
    vec2 d = vec2(fract(p.x * 30.0) - 0.5, 0.5 - p.y);
    float drip = smoothstep(0.12, 0.0, abs(d.x)) * step(d.y, len) + smoothstep(0.25, 0.1, length(vec2(d.x, (d.y - len) * 30.0) / vec2(1.0, 1.0))) * step(0.6, h);
    col += GFX_PRIMARY * drip * 0.5;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
