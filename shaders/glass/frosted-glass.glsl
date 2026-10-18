// @id frosted-glass
// @name Frosted Glass
// @category glass
// @description A frosted pane over soft drifting colour blobs, with fine grain and a bright bevel along the window edge.
// @tags glass, frosted, blur, soft, modern, vibrancy
// @mode background
// @uses hash value
// @color PRIMARY #7A5CFF
// @color SECONDARY #10121C
// @color ACCENT #FF7AC6
// @limitation Ghostty cannot see the desktop behind the window, so the "backdrop" is procedural.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Large soft blobs = an out-of-focus backdrop seen through frosting.
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * 0.07 + fi * 1.9) * 0.6 * gfx_aspect() * 0.5, cos(t * 0.05 + fi * 2.7) * 0.35);
        vec3 bc = i == 0 ? GFX_PRIMARY : i == 1 ? GFX_ACCENT : i == 2 ? GFX_PRIMARY * 0.6 + GFX_ACCENT * 0.4 : vec3(0.2, 0.6, 0.9);
        col += bc * 0.45 * exp(-dot(p - c, p - c) * 5.0);
    }
    // Frost: per-pixel grain plus a slightly coarser mottling.
    float grain = hash12(fragCoord) - 0.5;
    float mottle = vnoise(p * 60.0) - 0.5;
    col += (grain * 0.035 + mottle * 0.03);
    col = mix(col, vec3(gfx_luma(col)) + 0.04, 0.25);
    // Bevel highlight along the top and left edges.
    float bevel = exp(-uv.y * iResolution.y / 3.0) * 0.0 + exp(-(1.0 - uv.y) * iResolution.y / (3.0 * gfx_dpi())) + exp(-uv.x * iResolution.x / (3.0 * gfx_dpi())) * 0.6;
    col += vec3(0.25) * bevel;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
