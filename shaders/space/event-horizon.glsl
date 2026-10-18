// @id event-horizon
// @name Event Horizon
// @category space
// @description The curved edge of an enormous black hole fills the bottom of the screen, starlight smeared into arcs along its rim.
// @tags space, black-hole, horizon, dark, lensing
// @mode background
// @uses hash fbm
// @color PRIMARY #FF7A3D
// @color SECONDARY #010104
// @color ACCENT #A9C6FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = vec2(0.0, -3.1);
    float R = 2.85;
    vec2 d = p - c;
    float r = length(d);
    float h = r - R;                            // height above the horizon
    vec3 col = GFX_SECONDARY;
    if (h > 0.0) {
        // Lensing: tangential stretching grows toward the horizon.
        float stretch = 1.0 + 0.08 / (h + 0.01);
        vec2 dir = d / r;
        vec2 tan_ = vec2(-dir.y, dir.x);
        vec2 q = vec2(dot(p, tan_) / stretch, h * 1.0) * 60.0 + vec2(t * 0.5 / stretch, 0.0);
        vec2 id = floor(q);
        float s = step(0.93, hash12(id)) * smoothstep(0.35, 0.0, abs(fract(q.y) - 0.5)) * smoothstep(0.5, 0.0, abs(fract(q.x) - 0.5) / stretch * 2.0);
        col += mix(GFX_ACCENT, vec3(1.0), 0.4) * s * 0.9;
        col += mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.0, 0.3, h)) * exp(-h * 25.0) * (0.6 + 0.4 * fbm(vec2(dot(p, tan_) * 6.0 - t * 0.2, 0.0)));
    } else {
        col = vec3(0.0);
    }
    col += GFX_PRIMARY * exp(-abs(h) * 300.0) * 0.8;   // photon sphere glint
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
