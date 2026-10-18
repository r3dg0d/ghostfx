// @id meteor-shower
// @name Meteor Shower
// @category space
// @description Shooting stars streak across a clear night sky above a dark treeline, bright heads trailing glowing tails.
// @tags space, meteors, night, stars, sky
// @mode background
// @uses hash fbm sdf
// @color PRIMARY #E6F0FF
// @color SECONDARY #030614
// @color ACCENT #6FA8FF
// @param RATE float 1.0 0.2 3.0 Meteors per second (approx.)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.25, smoothstep(0.5, -0.5, p.y));
    vec2 g = p * 80.0;
    vec2 id = floor(g);
    float h = hash12(id);
    col += vec3(0.85) * step(0.985, h) * smoothstep(0.3, 0.0, length(fract(g) - 0.5)) * (0.6 + 0.4 * sin(t * 2.0 + h * 50.0));

    vec2 dir = normalize(vec2(-1.0, -0.45));
    for (int i = 0; i < 8; i++) {
        float fi = float(i);
        float period = 8.0 / P_RATE;
        float lt = t + fi * period / 8.0;
        float cyc = floor(lt / period);
        float k = fract(lt / period) * 3.0;            // active during k in [0, 1]
        if (k > 1.0) continue;
        vec2 start = (hash22(vec2(fi, cyc)) - 0.5) * vec2(gfx_aspect(), 0.6) + vec2(0.3, 0.25);
        vec2 head = start + dir * k * 0.9;
        vec2 rel = p - head;
        float along = -dot(rel, dir);
        float across = abs(dot(rel, vec2(-dir.y, dir.x)));
        float tail = smoothstep(0.35, 0.0, along) * step(0.0, along) * smoothstep(0.003, 0.0, across);
        float bright = sin(k * 3.1416);
        col += mix(GFX_ACCENT, GFX_PRIMARY, smoothstep(0.3, 0.0, along)) * tail * bright;
        col += GFX_PRIMARY * glow(length(rel), 0.004) * bright * 0.6;
    }
    // Treeline silhouette.
    float tree = -0.4 + 0.05 * fbm(vec2(p.x * 12.0, 0.0)) + 0.03 * vnoise(vec2(p.x * 60.0, 2.0));
    col = mix(col, vec3(0.0, 0.005, 0.01), smoothstep(0.003, 0.0, p.y - tree));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
