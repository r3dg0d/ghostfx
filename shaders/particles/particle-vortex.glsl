// @id particle-vortex
// @name Particle Vortex
// @category particles
// @description Thousands of motes spiral into a central drain, orbiting faster the closer they get.
// @tags particles, vortex, spiral, hypnotic, cyan
// @mode background
// @uses hash
// @color PRIMARY #4DE8FF
// @color SECONDARY #05060D
// @color ACCENT #B66BFF
// @param RINGS float 26.0 10.0 50.0 Number of orbit rings

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float r = length(p);
    float a = atan(p.y, p.x);
    // Rings in log-radius drift inward; angular speed ~ 1/r (Keplerian feel).
    float lr = log(r + 1e-3) * P_RINGS * 0.25 + t * 0.6;
    float ring = floor(lr);
    float fr = fract(lr) - 0.5;
    float slots = 18.0 + 6.0 * hash11(ring);
    float omega = 0.35 / (r + 0.08);
    float ang = (a + t * omega) / 6.2831 * slots + hash11(ring * 3.1) * 10.0;
    float sid = floor(ang);
    float fa = fract(ang) - 0.5;
    float h = hash12(vec2(ring, sid));
    float on = step(0.45, h);
    float d = length(vec2(fa * 0.6, fr));
    float mote = on * smoothstep(0.18, 0.0, d) * smoothstep(0.02, 0.25, r);

    vec3 col = GFX_SECONDARY + mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(0.0, 0.6, r)) * 0.18 * exp(-r * 3.0);
    col += mix(GFX_PRIMARY, GFX_ACCENT, h) * mote * 1.2;
    col *= smoothstep(0.0, 0.05, r);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
