// @id floating-particles
// @name Floating Particles
// @category particles
// @description Soft out-of-focus orbs drift upward on several depth planes, like dust caught in a beam of light.
// @tags particles, bokeh, calm, soft, minimal
// @mode background
// @uses hash
// @color PRIMARY #7C9CFF
// @color SECONDARY #0B0D18
// @color ACCENT #FFB3E6
// @param COUNT float 1.0 0.3 2.0 Particle density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * 0.05 * (p.y + 0.5);

    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float depth = fi / float(GFX_LAYERS);           // 0 = near, 1 = far
        float sc = mix(3.0, 12.0, depth);
        vec2 q = p * sc + vec2(t * 0.05 * (1.0 - depth), t * mix(0.18, 0.06, depth)) * sc * 0.4;
        q += fi * 17.3;
        vec2 id = floor(q);
        vec2 f = fract(q) - 0.5;
        vec2 h = hash22(id);
        if (hash12(id + 9.1) > 0.35 * P_COUNT) continue;
        vec2 o = (h - 0.5) * 0.6 + 0.08 * vec2(sin(t * 0.7 + h.x * 20.0), cos(t * 0.5 + h.y * 20.0));
        float d = length(f - o);
        // Near particles are larger and blurrier (bokeh), far ones crisp.
        float r = mix(0.28, 0.07, depth);
        float blur = mix(0.18, 0.02, depth);
        float disc = smoothstep(r, r - blur, d);
        vec3 c = mix(GFX_PRIMARY, GFX_ACCENT, hash12(id + 3.3));
        col += c * disc * mix(0.22, 0.6, depth) * (0.7 + 0.3 * sin(t + h.x * 30.0));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
