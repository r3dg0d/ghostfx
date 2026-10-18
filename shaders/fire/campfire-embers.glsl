// @id campfire-embers
// @name Campfire Embers
// @category fire
// @description Glowing embers float up from an unseen campfire, swaying and flickering out in the cool night air.
// @tags fire, embers, particles, cozy, warm, night
// @mode background
// @uses hash
// @color PRIMARY #FF6A1A
// @color SECONDARY #1A0A06
// @color ACCENT #FFD27A
// @param EMBERS float 1.0 0.3 2.0 Ember density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Warm glow from below, gently flickering.
    float flick = 0.85 + 0.1 * sin(t * 7.0) + 0.05 * sin(t * 13.0);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * 0.35 * flick * exp(-length(vec2(p.x * 0.7, p.y + 0.7)) * 3.2);

    for (int i = 0; i < GFX_LAYERS; i++) {
        float fi = float(i);
        float sc = 9.0 + fi * 5.0;
        vec2 q = p * sc;
        q.y -= t * (1.2 + 0.4 * fi);
        vec2 id = floor(q);
        float h = hash12(id + fi * 17.0);
        if (h > 0.3 * P_EMBERS) continue;
        // Each ember sways on its own phase; stretch along motion for a streak.
        vec2 f = fract(q) - 0.5;
        f.x += 0.3 * sin(t * 1.5 + h * 50.0 + q.y * 0.7);
        f.x += (hash12(id + 5.0) - 0.5) * 0.4;
        float d = length(f * vec2(1.0, 0.45));
        float life = smoothstep(0.6, -0.2, p.y) + 0.15;
        float b = smoothstep(0.08, 0.0, d) * (0.6 + 0.4 * sin(t * 10.0 + h * 90.0)) * life;
        col += mix(GFX_PRIMARY, GFX_ACCENT, h * 3.0) * b * (1.4 - fi * 0.15);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
