// @id gravitational-waves
// @name Gravitational Waves
// @category space
// @description Two compact stars spiral together, sending quadrupole ripples through a grid of spacetime that chirp faster as they merge.
// @tags gravity, waves, ligo, physics, grid, space
// @mode background
// @uses sdf
// @color PRIMARY #6B8CFF
// @color SECONDARY #03030A
// @color ACCENT #FFC46B
// @param CYCLE float 30.0 10.0 120.0 Seconds per inspiral and merger

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    vec2 c = p - vec2(0.35, 0.0);
    // Inspiral: separation shrinks and orbital frequency rises (chirp).
    float sep = 0.12 * pow(1.0 - k, 0.25) + 0.003;
    float phase = -8.0 * pow(1.0 - k, 0.62) * 20.0;
    vec2 a = vec2(cos(phase), sin(phase)) * sep;
    float r = length(c);
    float ang = atan(c.y, c.x);
    // Quadrupole wave: 2*angle pattern travelling outward.
    float w = sin(2.0 * ang - phase * 2.0 + r * 40.0 / max(sep * 8.0, 0.25)) * exp(-r * 1.5) * smoothstep(0.02, 0.1, r);
    vec2 q = c + c / max(r, 1e-3) * w * 0.012;
    float grid = grid_lines(q * 14.0, 1.2 * gfx_dpi());
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * grid * (0.15 + 0.35 * abs(w));
    col += GFX_ACCENT * (exp(-length(c - a) * 120.0) + exp(-length(c + a) * 120.0));
    col += vec3(1.0) * exp(-r * 30.0) * smoothstep(0.97, 1.0, k) * gfx_flash(1.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
