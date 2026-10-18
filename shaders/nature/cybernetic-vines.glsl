// @id cybernetic-vines
// @name Cybernetic Vines
// @category nature
// @description Metallic vines with glowing nodes creep up from the bottom of the window, branching and curling as they grow.
// @tags vines, cyborg, organic, growth, green, nature
// @mode background
// @uses hash value
// @color PRIMARY #4DFF9A
// @color SECONDARY #030604
// @color ACCENT #8C99A8
// @param CYCLE float 24.0 8.0 90.0 Seconds per growth cycle

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    float grow = smoothstep(0.0, 0.7, k) * (1.0 - smoothstep(0.9, 1.0, k));
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < 7; i++) {
        float fi = float(i);
        float x0 = ((fi + 0.5) / 7.0 - 0.5) * gfx_aspect() * 0.95;
        float h = 0.25 + 0.55 * hash11(fi);
        float top = -0.5 + h * grow;
        // Main stem: a sinuous curve; branches curl off at hashed heights.
        float y = p.y;
        float sx = x0 + 0.04 * sin(y * 9.0 + fi * 2.0) + 0.02 * (vnoise(vec2(y * 5.0, fi)) - 0.5);
        float d = abs(p.x - sx);
        float stem = smoothstep(0.004, 0.0015, d) * step(y, top) * step(-0.5, y);
        col += GFX_ACCENT * stem * 0.8;
        for (int j = 0; j < 3; j++) {
            float fj = float(j);
            float by = -0.5 + h * (0.3 + 0.25 * fj);
            if (by > top) break;
            float side = mod(fj + fi, 2.0) < 1.0 ? 1.0 : -1.0;
            vec2 q = p - vec2(x0 + 0.04 * sin(by * 9.0 + fi * 2.0), by);
            float ang = atan(q.y, q.x * side);
            float rr = length(q);
            float spiral = abs(rr - 0.05 * (1.0 - ang / 3.1416 * 0.3));
            float curl = smoothstep(0.004, 0.0015, spiral) * step(0.0, q.y + 0.02) * step(rr, 0.07) * step(0.0, q.x * side);
            col += GFX_ACCENT * curl * 0.7;
            col += GFX_PRIMARY * exp(-length(q) * 120.0) * (0.6 + 0.4 * sin(t * 2.0 + fi + fj));
        }
        col += GFX_PRIMARY * exp(-length(p - vec2(sx, top)) * 90.0) * grow;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
