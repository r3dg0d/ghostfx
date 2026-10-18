// @id rainstorm
// @name Rainstorm
// @category nature
// @description Heavy rain in deep layers, near drops blurred and fast, with splashes rippling across puddles below.
// @tags rain, storm, weather, grey, calm, heavy
// @mode background
// @uses hash
// @color PRIMARY #AFC3DA
// @color SECONDARY #0E1218
// @color ACCENT #3A4A60
// @param DENSITY float 1.0 0.3 2.0 Rain density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.5, smoothstep(0.5, -0.5, p.y));
    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float depth = 1.0 + fi * 0.6;
        float sc = 40.0 * depth;
        vec2 q = vec2((p.x + p.y * 0.08) * sc, p.y * 4.0 * depth + t * 12.0 / sqrt(depth)) + fi * 13.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.12 * P_DENSITY) continue;
        float fy = fract(q.y);
        float fx = abs(fract(q.x) - 0.5);
        float w = 0.08 + 0.12 / depth;
        float streak = smoothstep(w, 0.0, fx) * smoothstep(0.0, 0.5, fy) * smoothstep(1.0, 0.6, fy);
        col += GFX_PRIMARY * streak * (0.5 / depth);
    }
    // Puddle splashes: rings in a squashed perspective near the bottom.
    if (p.y < -0.35) {
        vec2 g = vec2(p.x * 12.0, (p.y + 0.35) * 60.0);
        vec2 id = floor(g);
        vec2 f = fract(g) - 0.5;
        float ph = fract(t * 1.2 + hash12(id));
        float ring = smoothstep(0.06, 0.0, abs(length(f * vec2(1.0, 2.5)) - ph * 0.45)) * (1.0 - ph) * step(0.5, hash12(id + 2.0));
        col += GFX_PRIMARY * ring * 0.4;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
