// @id rainy-window
// @name Rainy Window
// @category glass
// @description A fogged-up window on a rainy evening: beaded droplets cling to the glass and warm lights glow beyond.
// @tags rain, window, cozy, condensation, bokeh, evening
// @mode glow
// @uses hash
// @color PRIMARY #FFB45C
// @color SECONDARY #121722
// @color ACCENT #6F8BB8
// @param BEADS float 1.0 0.3 2.0 Droplet density

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Warm interior lights beyond, heavily defocused.
    vec3 fx = mix(GFX_SECONDARY, GFX_ACCENT * 0.4, smoothstep(0.5, -0.5, p.y));
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        vec2 c = (hash22(vec2(fi, 3.0)) - 0.5) * vec2(gfx_aspect(), 0.8);
        fx += mix(GFX_PRIMARY, GFX_ACCENT, step(0.7, hash11(fi))) * 0.35 * smoothstep(0.16, 0.1, length(p - c));
    }
    fx = mix(fx, vec3(gfx_luma(fx)) + 0.05, 0.2);   // condensation haze

    // Static beads: many small drops, each a tiny lens with a bright rim.
    vec3 light = vec3(0.0);
    vec2 lens = vec2(0.0);
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        vec2 g = p * (28.0 + fi * 22.0);
        vec2 id = floor(g);
        if (hash12(id + fi) > 0.55 * P_BEADS) continue;
        vec2 f = fract(g) - 0.5 - (hash22(id + fi * 7.0) - 0.5) * 0.5;
        float r = 0.14 + 0.16 * hash12(id + 3.0);
        float d = length(f * vec2(1.0, 0.9));
        float bead = smoothstep(r, r * 0.7, d);
        lens += f / r * bead;
        light += vec3(0.9, 0.95, 1.0) * bead * smoothstep(r * 0.35, 0.0, length(f - vec2(-0.3, 0.35) * r)) * 0.9;
        light += GFX_PRIMARY * bead * 0.1 + vec3(0.04) * smoothstep(r, r * 0.8, d) * (1.0 - bead);
    }
    // Occasional runner sliding down, clearing a trail.
    float cw = 0.2;
    float col_ = floor(p.x / cw);
    float rh = hash11(col_ * 2.7);
    float ry = 0.6 - fract(t * 0.05 * (0.5 + rh) + rh) * 1.4;
    vec2 rd = vec2(fract(p.x / cw) - 0.5, (p.y - ry) / cw);
    float runner = step(0.6, rh) * smoothstep(0.12, 0.06, length(rd));
    light += vec3(1.0) * runner * 0.15;
    fx += (vec3(0.15) * step(0.6, rh) * smoothstep(0.08, 0.0, abs(rd.x)) * step(ry, p.y)) * 0.6;
    fx += GFX_PRIMARY * length(lens) * 0.05;
    fragColor = gfx_compose_glow(uv, gfx_term(uv), fx, light);
}
