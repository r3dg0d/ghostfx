// @id lightning
// @name Lightning
// @category electric
// @description Forked lightning tears down from dark clouds every few seconds, briefly lighting the whole sky.
// @tags lightning, storm, electric, dramatic, blue
// @mode background
// @uses fbm hash sdf
// @flashing true
// @color PRIMARY #CFE0FF
// @color SECONDARY #05070F
// @color ACCENT #5A6FB5
// @param INTERVAL float 3.0 1.0 10.0 Average seconds between strikes
// @preset subtle INTERVAL=6.0

// Horizontal offset of a bolt at height y: layered noise, more jagged at small scale.
float bolt_x(float y, float seed) {
    return (gnoise(vec2(y * 3.0, seed)) * 0.25 + gnoise(vec2(y * 11.0, seed + 3.0)) * 0.08 + gnoise(vec2(y * 40.0, seed + 7.0)) * 0.025);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float slot = floor(t / P_INTERVAL);
    float lt = t - slot * P_INTERVAL;
    float seed = hash11(slot) * 100.0;
    // Return strokes: two quick pulses then decay.
    float life = exp(-lt * 6.0) * (0.7 + 0.3 * step(0.12, lt) * step(lt, 0.2)) * step(0.0, lt);

    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.2, smoothstep(-0.5, 0.5, p.y));
    float clouds = fbm(vec2(p.x * 2.0 + t * 0.03, p.y * 3.0));
    col += GFX_ACCENT * clouds * smoothstep(0.1, 0.5, p.y) * 0.3;

    float x0 = (hash11(slot + 0.5) - 0.5) * gfx_aspect() * 0.8;
    float reach = -0.5 + 0.3 * hash11(slot + 2.0);
    float main_ = 0.0;
    if (p.y > reach) {
        float d = abs(p.x - x0 - bolt_x(p.y, seed));
        main_ = smoothstep(0.004, 0.0, d) + glow(d, 0.006) * 0.4;
    }
    // A branch splitting off partway down.
    float by = 0.1 * hash11(slot + 4.0);
    float branch = 0.0;
    if (p.y < by && p.y > by - 0.35) {
        float k = (by - p.y);
        float bx = x0 + bolt_x(by, seed) + k * (hash11(slot + 5.0) - 0.5) * 1.6 + bolt_x(p.y, seed + 20.0) * 0.5;
        float d = abs(p.x - bx);
        branch = (smoothstep(0.003, 0.0, d) + glow(d, 0.004) * 0.3) * smoothstep(0.35, 0.0, k);
    }
    float flash = gfx_flash(life);
    col += GFX_PRIMARY * (main_ + branch * 0.7) * flash * 1.5;
    col += GFX_ACCENT * flash * clouds * 0.5 * smoothstep(-0.2, 0.5, p.y);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
