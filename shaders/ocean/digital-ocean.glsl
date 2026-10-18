// @id digital-ocean
// @name Digital Ocean
// @category ocean
// @description An ocean rendered as data: a perspective lattice of glowing points rises and falls in rolling swells toward the horizon.
// @tags ocean, data, points, wireframe, cyan, digital
// @mode background
// @uses gradient
// @color PRIMARY #33E6FF
// @color SECONDARY #020611
// @color ACCENT #3D5BFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = 0.15;
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.12 * exp(-abs(p.y - hy) * 6.0);
    if (p.y < hy) {
        // Find the lattice point nearest this pixel by inverting the projection
        // of the (undisplaced) plane, then compare against its displaced screen y.
        float dy = hy - p.y;
        float z = 0.3 / dy;
        vec2 w = vec2(p.x * z, z) * 4.0;
        vec2 id = floor(w + 0.5);
        float best = 0.0;
        for (int k = -1; k <= 2; k++) {
            vec2 g = id + vec2(0.0, float(k));
            float zz = g.y / 4.0;
            float hgt = 0.12 * sin(g.x * 0.4 + t * 1.2) * sin(g.y * 0.3 - t * 0.9) + 0.06 * gnoise(g * 0.2 + t * 0.2);
            vec2 sp = vec2(g.x / 4.0 / zz, hy - 0.3 / zz + hgt / zz * 0.6);
            float d = length(p - sp);
            float r = 0.004 / (0.4 + zz * 0.15) + 0.0008;
            best = max(best, smoothstep(r, 0.0, d) * exp(-zz * 0.08) * (0.6 + 0.4 * sin(hgt * 20.0)));
        }
        col += mix(GFX_ACCENT, GFX_PRIMARY, best) * best * 1.4;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
