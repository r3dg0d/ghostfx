// @id cherry-blossoms
// @name Cherry Blossoms
// @category particles
// @description Pink sakura petals with notched tips float on a spring breeze across a soft dusk gradient.
// @tags sakura, petals, pink, spring, particles, soft
// @mode background
// @uses hash
// @color PRIMARY #FFB7D0
// @color SECONDARY #1A1020
// @color ACCENT #FF7AA8
// @param DENSITY float 1.0 0.3 2.0 Petal density
// @param WIND float 1.0 0.0 2.5 Breeze strength

// Petal: an ellipse with a small notch at the outer tip.
float petal(vec2 p) {
    float d = length(p * vec2(1.0, 1.7)) - 0.22;
    float notch = length(p - vec2(0.23, 0.0)) - 0.06;
    return max(d, -notch);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_SECONDARY + GFX_ACCENT * 0.12, smoothstep(-0.6, 0.6, p.y));

    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float sc = 4.0 + fi * 2.2;
        vec2 q = p * sc + vec2(-t * 0.45 * P_WIND, t * 0.32) + fi * 7.7;
        q.y += 0.3 * sin(q.x * 0.6 + t * 0.5);
        vec2 id = floor(q);
        if (hash12(id) > 0.32 * P_DENSITY) continue;
        vec2 h = hash22(id + 3.0);
        vec2 f = fract(q) - 0.5 - (h - 0.5) * 0.4;
        f = gfx_rot(t * (0.8 + h.x) + h.y * 6.28) * f;
        f.y /= 0.35 + 0.65 * abs(sin(t * (0.7 + h.y) + h.x * 9.0));
        float a = smoothstep(0.015, 0.0, petal(f * 1.4));
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, length(f) * 2.5 * h.x);
        col = mix(col, c * (1.0 - 0.12 * fi), a * (0.95 - 0.1 * fi));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
