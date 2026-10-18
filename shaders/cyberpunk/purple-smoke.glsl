// @id purple-smoke
// @name Purple Smoke
// @category cyberpunk
// @description Thick violet smoke curls through neon backlight, its wisps advected along a slowly turning flow.
// @tags smoke, purple, neon, cyberpunk, atmospheric
// @mode background
// @uses fbm
// @color PRIMARY #9B4DFF
// @color SECONDARY #07030E
// @color ACCENT #FF4FD8

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.6;
    float t = gfx_time() * 0.25;
    // Advect noise along a divergence-free-ish flow built from fbm gradients.
    vec2 q = p;
    for (int i = 0; i < 3; i++) {
        float e = 0.05;
        float n = fbm(q + t);
        vec2 grad = vec2(fbm(q + vec2(e, 0.0) + t) - n, fbm(q + vec2(0.0, e) + t) - n) / e;
        q += vec2(grad.y, -grad.x) * 0.08;      // curl: move along the iso-lines
    }
    float smoke = fbm(q * 1.5 + vec2(0.0, -t * 0.6));
    float wisps = pow(smoke, 3.0);
    vec3 back = mix(GFX_SECONDARY, GFX_ACCENT * 0.25, smoothstep(0.7, -0.6, p.y + p.x * 0.2));
    vec3 col = back + mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.3, 0.8, smoke)) * wisps * 1.3;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
