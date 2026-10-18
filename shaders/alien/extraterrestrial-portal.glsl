// @id extraterrestrial-portal
// @name Extraterrestrial Portal
// @category alien
// @description An unstable alien gateway: a crackling elliptical rim spits tendrils of energy around a churning green interior.
// @tags portal, alien, green, energy, unstable
// @mode background
// @uses fbm hash
// @flashing true
// @color PRIMARY #3DFF8A
// @color SECONDARY #02070A
// @color ACCENT #D9FF6B

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = (p - vec2(0.3 * gfx_aspect() * 0.5, 0.0)) * vec2(1.0, 0.75);
    float r = length(q);
    float a = atan(q.y, q.x);
    float R = 0.28 + 0.015 * sin(a * 7.0 + t * 3.0) + 0.02 * (fbm(vec2(a * 3.0, t)) - 0.5);
    vec3 col = GFX_SECONDARY;

    if (r < R) {
        // Swirl in Cartesian space so there is no atan() seam.
        vec2 s = gfx_rot(2.0 / (r + 0.15) + t * 0.6) * q * 5.0 + vec2(0.0, -t * 0.5);
        float n = fbm(s);
        col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.7, n);
        col += GFX_ACCENT * pow(n, 4.0) * 0.6;
        col *= smoothstep(0.0, R, r) * 0.6 + 0.4;
    }
    float rim = exp(-abs(r - R) * 70.0);
    float flick = 0.75 + 0.25 * sin(t * 13.0 + a * 5.0);
    col += GFX_ACCENT * rim * flick * 1.2;
    // Tendrils: ridged noise arcing outward from the rim.
    float ten = pow(ridged(vec2(a * 4.0, (r - R) * 5.0 - t * 1.5)), 6.0) * smoothstep(0.35, 0.0, r - R) * step(R, r);
    col += GFX_PRIMARY * ten * gfx_flash(1.0) * 1.3;
    col += GFX_PRIMARY * 0.15 * exp(-max(r - R, 0.0) * 8.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
