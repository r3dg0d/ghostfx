// @id molten-metal
// @name Molten Metal
// @category metallic
// @description Streams of incandescent liquid metal pour and braid across the screen, cooling to a dark sheen at their edges.
// @tags molten, metal, foundry, hot, orange
// @mode background
// @uses fbm lighting
// @color PRIMARY #FF6A00
// @color SECONDARY #0D0604
// @color ACCENT #FFF0B0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.6;
    float t = gfx_time();
    // Flow along x with lateral meanders; ridges = the stream cores.
    vec2 q = vec2(p.x - t * 0.25, p.y);
    q.y += 0.25 * fbm(vec2(q.x * 0.6, t * 0.05));
    float flow = ridged(vec2(q.x * 0.8, q.y * 2.5));
    float temp = pow(clamp(flow, 0.0, 1.0), 2.5);
    vec3 hot = mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.5, 1.0, temp));
    // Cooled metal keeps a dim metallic reflection.
    float sheen = pow(0.5 + 0.5 * sin(q.y * 8.0 + fbm(q * 2.0) * 4.0), 6.0);
    vec3 cold = GFX_SECONDARY + vec3(0.12, 0.1, 0.1) * sheen;
    vec3 col = mix(cold, hot * 1.2, smoothstep(0.15, 0.5, temp));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
