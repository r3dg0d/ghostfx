// @id aurora-space
// @name Aurora from Orbit
// @category space
// @description Seen from orbit, green and violet auroral curtains ripple above the curved night side of a planet.
// @tags space, aurora, planet, orbit, green
// @mode background
// @uses fbm hash
// @color PRIMARY #3DFFB0
// @color SECONDARY #01030A
// @color ACCENT #B26BFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 pc = vec2(0.0, -2.35);
    float R = 2.0;
    float d = length(p - pc) - R;              // height above the limb
    vec3 col = GFX_SECONDARY;
    vec2 g = p * 80.0;
    col += vec3(0.7) * step(0.99, hash12(floor(g))) * smoothstep(0.3, 0.0, length(fract(g) - 0.5)) * step(0.0, d);

    if (d < 0.0) {
        // Night side with a few city lights.
        col = vec3(0.005, 0.008, 0.015);
        vec2 cg = p * 120.0;
        col += vec3(1.0, 0.7, 0.35) * step(0.985, hash12(floor(cg))) * fbm(p * 6.0) * 0.8;
    }
    col += vec3(0.15, 0.35, 0.8) * exp(-abs(d) * 60.0) * 0.6;      // atmosphere rim

    // Curtains: vertical streaks in "along-limb" coordinate, height-limited.
    float along = (p.x) * 3.0;
    float sway = fbm(vec2(along * 0.8 + t * 0.05, t * 0.1));
    float curtain = pow(fbm(vec2(along * 6.0 + sway * 4.0, t * 0.2)), 2.0);
    float h = smoothstep(0.0, 0.02, d) * exp(-d * (6.0 + 4.0 * sway));
    col += mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.02, 0.2, d)) * curtain * h * 1.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
