// @id quantum-foam
// @name Quantum Foam
// @category experimental
// @description Planck-scale bubbles flicker into existence and pop at several scales at once, a restless froth of virtual particles.
// @tags quantum, foam, bubbles, abstract, colorful
// @mode background
// @uses voronoi hash
// @color PRIMARY #6CF2FF
// @color SECONDARY #04040B
// @color ACCENT #FF6CD9

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float sc = 5.0 * pow(2.2, fi);
        vec3 v = voronoi(p * sc + fi * 7.0, t * (0.4 + fi * 0.3));
        // Each bubble lives for a random short time, then pops (bright rim flash).
        float life = fract(t * (0.5 + fi * 0.3) + v.z * 7.0);
        float alive = step(0.4, hash11(v.z * 91.0 + floor(t * (0.5 + fi * 0.3) + v.z * 7.0)));
        float rim = smoothstep(0.12, 0.0, v.y - v.x) * alive;
        float pop = smoothstep(0.85, 1.0, life);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, v.z);
        col += c * rim * (0.15 + 0.6 * pop) * (1.0 - fi * 0.25);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
