// @id falling-leaves
// @name Falling Leaves
// @category particles
// @description Autumn leaves tumble and flip as they drift down through warm late-afternoon light.
// @tags autumn, leaves, particles, warm, nature
// @mode background
// @uses hash sdf
// @color PRIMARY #E2611B
// @color SECONDARY #1C120C
// @color ACCENT #F2B33D
// @param DENSITY float 1.0 0.3 2.0 Leaf density

// Pointed leaf: intersection of two offset circles plus a midrib.
float sd_leaf(vec2 p) {
    float d = max(length(p - vec2(0.12, 0.0)) - 0.2, length(p + vec2(0.12, 0.0)) - 0.2);
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_SECONDARY + GFX_ACCENT * 0.12, smoothstep(-0.5, 0.6, p.y + p.x * 0.2));

    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float sc = 3.0 + fi * 1.8;
        vec2 q = p * sc + vec2(t * 0.25, t * (0.45 - 0.08 * fi)) + fi * 13.0;
        vec2 id = floor(q);
        if (hash12(id) > 0.4 * P_DENSITY) continue;
        vec2 f = fract(q) - 0.5;
        vec2 h = hash22(id + 1.0);
        f.x += 0.18 * sin(t * (0.8 + h.x) + h.y * 10.0);
        // Spin in-plane and fake a 3D flip by squashing one axis.
        f = gfx_rot(t * (0.6 + h.x) + h.y * 6.0) * f;
        float flip = 0.25 + 0.75 * abs(cos(t * (0.9 + h.y) + h.x * 5.0));
        vec2 lp = f / vec2(1.0, flip);
        float d = sd_leaf(lp * 1.6) / 1.6;
        float leaf = smoothstep(0.012, 0.0, d);
        float rib = smoothstep(0.012, 0.0, abs(lp.y)) * step(abs(lp.x), 0.12);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, h.x);
        c = mix(c, vec3(0.6, 0.12, 0.05), step(0.7, h.y));
        c *= 0.65 + 0.35 * flip - rib * 0.3;
        col = mix(col, c * (1.0 - fi * 0.18), leaf);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
