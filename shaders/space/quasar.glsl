// @id quasar
// @name Quasar
// @category space
// @description A blazing galactic core fires two knotted relativistic jets into space, its glare split by diffraction spikes.
// @tags space, quasar, jets, bright, energy
// @mode background
// @uses fbm
// @color PRIMARY #7DB9FF
// @color SECONDARY #020208
// @color ACCENT #FFE6C2

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.3, 0.05);
    vec2 j = gfx_rot(0.6) * c;
    float r = length(c);
    vec3 col = GFX_SECONDARY;
    // Host galaxy haze.
    col += GFX_ACCENT * 0.12 * exp(-length(c * vec2(1.0, 1.6)) * 4.0);
    // Jets along the rotated x axis, with knots travelling outward.
    float w = 0.006 + abs(j.x) * 0.05;
    float jet = exp(-abs(j.y) / w) * smoothstep(0.9, 0.05, abs(j.x));
    float knots = 0.6 + 0.4 * fbm(vec2(abs(j.x) * 12.0 - t * 1.5, j.y * 40.0));
    col += GFX_PRIMARY * jet * knots * 1.2;
    // Core and diffraction spikes.
    col += GFX_ACCENT * exp(-r * 35.0) * 2.0;
    float spikes = exp(-abs(c.x) * 400.0) * exp(-abs(c.y) * 6.0) + exp(-abs(c.y) * 400.0) * exp(-abs(c.x) * 6.0);
    col += GFX_ACCENT * spikes * (0.8 + 0.2 * sin(t * 2.0));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
