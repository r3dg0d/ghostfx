// @id neon-fireflies
// @name Neon Fireflies
// @category particles
// @description Fireflies in electric pink, cyan and lime loop through the dark, each trailing a fading neon streak.
// @tags fireflies, neon, trails, particles, colorful
// @mode background
// @uses hash color
// @color PRIMARY #FF3DB8
// @color SECONDARY #05040A
// @color ACCENT #3DF5FF
// @param COUNT int 14 4 30 Number of fireflies

vec2 ff_path(float i, float t) {
    vec2 h = hash22(vec2(i, 7.0));
    return vec2(0.8 * sin(t * (0.21 + 0.2 * h.x) + i * 2.1) * gfx_aspect() * 0.5,
                0.38 * sin(t * (0.33 + 0.2 * h.y) + i * 1.3) * cos(t * 0.11 + i));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < P_COUNT; i++) {
        float fi = float(i);
        vec3 c = hsv2rgb(vec3(fract(hash11(fi * 3.3) * 0.5 + 0.8), 0.8, 1.0));
        float blink = 0.4 + 0.6 * pow(0.5 + 0.5 * sin(t * (1.0 + hash11(fi)) + fi), 3.0);
        float acc = 0.0;
        for (int k = 0; k < 8; k++) {
            float fk = float(k);
            float d = length(p - ff_path(fi, t - fk * 0.06));
            acc += exp(-d * d * 40000.0 / (1.0 + fk)) * (1.0 - fk / 8.0);
        }
        float head = length(p - ff_path(fi, t));
        col += c * (acc * 0.5 + 0.0025 / (head * head + 0.0006) * 0.1) * blink;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
