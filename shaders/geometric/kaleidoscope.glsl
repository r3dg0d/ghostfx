// @id kaleidoscope
// @name Kaleidoscope
// @category geometric
// @description Coloured shards tumble inside mirrored wedges, folding into an ever-changing symmetric mandala.
// @tags kaleidoscope, symmetry, colorful, mandala, trippy
// @mode background
// @uses distortion fbm color
// @color PRIMARY #FF4D6D
// @color SECONDARY #0A0614
// @color ACCENT #4DD2FF
// @param SEGMENTS float 8.0 3.0 16.0 Mirror segments

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = kaleido(gfx_rot(t * 0.05) * p, floor(P_SEGMENTS) * 2.0);
    q = q * 2.5 + vec2(t * 0.1, 0.0);
    float n = fbm(q + fbm(q * 1.5 - t * 0.1));
    float shards = abs(sin(q.x * 3.0 + n * 4.0)) * abs(cos(q.y * 3.0 - n * 3.0));
    vec3 col = cospal(n + t * 0.03, vec3(0.5), vec3(0.5), vec3(1.0, 1.0, 1.0), vec3(0.0, 0.1, 0.2));
    col = mix(col, mix(GFX_PRIMARY, GFX_ACCENT, n), 0.4);
    col *= 0.25 + 0.9 * smoothstep(0.2, 0.9, shards);
    col *= smoothstep(1.1, 0.2, length(p));
    col = mix(GFX_SECONDARY, col, 0.9);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
