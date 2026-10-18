// @id synthwave-sunset
// @name Synthwave Sunset
// @category cyberpunk
// @description A huge striped sun sinks behind wireframe mountains while a magenta grid scrolls toward the viewer.
// @tags synthwave, sunset, 80s, retro, neon, outrun
// @mode background
// @uses hash value sdf
// @color PRIMARY #FF3EA5
// @color SECONDARY #12021F
// @color ACCENT #FFD319

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = -0.08;
    vec3 col = mix(GFX_PRIMARY * 0.35, GFX_SECONDARY, smoothstep(hy, 0.5, p.y));
    // Stars.
    vec2 sg = p * 60.0;
    col += vec3(0.8) * step(0.985, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5)) * smoothstep(0.1, 0.3, p.y);
    // Sun with horizontal cut stripes that widen toward the bottom.
    vec2 sc = p - vec2(0.0, 0.12);
    float sd = length(sc);
    float stripes = step(0.5, fract((sc.y + 0.3) * 18.0 - t * 0.3)) + step(0.06, sc.y);
    float sun = smoothstep(0.24, 0.235, sd) * clamp(stripes + smoothstep(-0.2, 0.05, sc.y), 0.0, 1.0);
    vec3 sunc = mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(-0.2, 0.2, sc.y));
    col = mix(col, sunc, sun * step(hy, p.y));
    col += GFX_PRIMARY * 0.25 * exp(-sd * 4.0) * step(hy, p.y);
    // Mountains silhouette with wireframe ridge lines.
    float m = hy + 0.12 * vnoise(vec2(p.x * 3.0, 0.0)) * smoothstep(0.1, 0.9, abs(p.x)) + 0.03 * vnoise(vec2(p.x * 12.0, 3.0));
    if (p.y < m && p.y > hy) {
        col = GFX_SECONDARY * 1.2;
        col += GFX_PRIMARY * 0.6 * smoothstep(0.004, 0.0, abs(p.y - m));
        col += GFX_PRIMARY * 0.2 * smoothstep(0.003, 0.0, abs(fract((p.y - hy) * 40.0) - 0.5) - 0.47);
    }
    // Grid floor.
    if (p.y < hy) {
        float dy = hy - p.y;
        float z = 0.2 / dy;
        vec2 g = vec2(p.x * z, z + t * 0.3) * 18.0;
        float line = grid_lines(g, 1.5 * gfx_dpi());
        col = GFX_SECONDARY * 0.8 + GFX_PRIMARY * line * exp(-z * 0.3) * 1.1;
        col += GFX_PRIMARY * 0.3 * exp(-dy * 15.0);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
