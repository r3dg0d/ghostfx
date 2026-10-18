// @id particle-trails
// @name Particle Trails
// @category particles
// @description Bright points race along looping orbits, leaving long smooth light trails that fade behind them.
// @tags particles, trails, light, neon, motion
// @mode background
// @uses hash sdf
// @color PRIMARY #FF4FD8
// @color SECONDARY #05040B
// @color ACCENT #4FF0FF
// @param COUNT int 7 2 14 Number of particles
// @param TRAIL float 1.2 0.3 3.0 Trail length in seconds

vec2 orbit(float i, float t) {
    vec2 h = hash22(vec2(i, 1.3));
    vec2 f = 0.25 + h * 0.6;
    return vec2(0.75 * sin(t * f.x + i * 1.7), 0.38 * sin(t * f.y * 1.3 + i * 2.9));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    const int SEG = 14;

    for (int i = 0; i < P_COUNT; i++) {
        float fi = float(i);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, hash11(fi * 7.1));
        vec2 prev = orbit(fi, t);
        float acc = 0.0;
        // Trail as a polyline through past positions, fading with age.
        for (int s = 1; s <= SEG; s++) {
            float age = float(s) / float(SEG) * P_TRAIL;
            vec2 cur = orbit(fi, t - age);
            float d = sd_segment(p, prev, cur);
            float fade = 1.0 - float(s - 1) / float(SEG);
            acc = max(acc, fade * fade * smoothstep(0.006, 0.0, d - 0.002 * fade));
            acc = max(acc, fade * 0.25 * glow(d, 0.004));
            prev = cur;
        }
        float head = glow(length(p - orbit(fi, t)), 0.008);
        col += c * (acc + head * 0.8);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
