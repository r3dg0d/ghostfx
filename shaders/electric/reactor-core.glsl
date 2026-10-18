// @id reactor-core
// @name Reactor Core
// @category electric
// @description A fusion reactor seen edge-on: magnetic confinement rings spin around a blinding plasma core that pulses with power.
// @tags reactor, fusion, plasma, rings, sci-fi, orange
// @mode background
// @uses fbm
// @color PRIMARY #FF8A2E
// @color SECONDARY #040304
// @color ACCENT #6BD5FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.4, 0.0);
    float r = length(c);
    float pulse = 0.75 + 0.25 * sin(t * 2.2);
    vec3 col = GFX_SECONDARY;
    // Plasma core: turbulent, bright, pulsing.
    vec2 sw = gfx_rot(t * 0.5) * c;
    float core = fbm(sw * 12.0 + t * 0.4);
    col += mix(GFX_PRIMARY, vec3(1.0, 0.95, 0.8), core) * exp(-r * 14.0) * 1.5 * pulse;
    // Tilted confinement rings (ellipses) rotating at different speeds.
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        float tilt = 0.25 + 0.15 * fi;
        vec2 q = gfx_rot(fi * 0.8 + t * 0.15 * (mod(fi, 2.0) < 1.0 ? 1.0 : -1.0)) * c;
        q.y /= tilt;
        float R = 0.13 + fi * 0.05;
        float d = abs(length(q) - R) * tilt;
        float a = atan(q.y, q.x);
        float marks = 0.6 + 0.4 * step(0.5, fract(a / 6.2831 * 12.0 - t * 0.5));
        col += mix(GFX_ACCENT, GFX_PRIMARY, fi / 3.0) * (smoothstep(0.004, 0.0, d) * marks + exp(-d * 120.0) * 0.2) * 0.8;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
