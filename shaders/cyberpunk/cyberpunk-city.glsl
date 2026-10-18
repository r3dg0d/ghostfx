// @id cyberpunk-city
// @name Cyberpunk City
// @category cyberpunk
// @description A rain-hazed neon skyline: layered towers with flickering windows, glowing signs and air traffic gliding between them.
// @tags cyberpunk, city, skyline, neon, night
// @mode background
// @uses hash fbm
// @color PRIMARY #FF2E97
// @color SECONDARY #07040F
// @color ACCENT #19D9FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.25, smoothstep(0.5, -0.4, p.y));
    col += GFX_ACCENT * 0.05 * fbm(p * 3.0 + t * 0.02);

    for (int L = 2; L >= 0; L--) {
        float fl = float(L);
        float w = 0.05 + 0.03 * fl;
        float x = p.x + t * 0.01 * (3.0 - fl) + fl * 3.7;
        float id = floor(x / w);
        float h = hash11(id * 1.31 + fl * 9.0);
        float top = -0.45 + (0.25 + 0.55 * h) * (1.0 - fl * 0.25);
        float lx = fract(x / w);
        float inB = step(p.y, top) * step(0.06, lx) * step(lx, 0.94);
        vec3 bc = mix(GFX_SECONDARY * 1.5, GFX_PRIMARY * 0.08, fl * 0.3) * (1.0 - fl * 0.15);
        // Windows: a grid that flickers on and off.
        vec2 wg = vec2(lx * 6.0, (p.y + t * 0.0) * 90.0 / (1.0 + fl));
        vec2 wid = floor(wg);
        float lit = step(0.8, hash12(wid + id * 7.0 + floor(t * 0.2 + hash11(id) * 9.0)));
        float win = lit * step(0.3, fract(wg.x)) * step(0.35, fract(wg.y));
        vec3 wc = mix(GFX_ACCENT, vec3(1.0, 0.8, 0.5), step(0.7, hash12(wid)));
        bc += wc * win * (0.6 - fl * 0.15);
        // A neon sign on some towers.
        float sign_ = step(0.75, h) * smoothstep(0.012, 0.0, abs(p.y - top + 0.06)) * step(0.15, lx) * step(lx, 0.85);
        bc += mix(GFX_PRIMARY, GFX_ACCENT, step(0.88, h)) * sign_ * (0.8 + 0.2 * sin(t * 6.0 + h * 40.0));
        col = mix(col, bc, inB);
        col += GFX_PRIMARY * 0.04 * smoothstep(0.08, 0.0, abs(p.y - top)) * step(0.75, h);
    }
    // Air traffic.
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float y = 0.05 + 0.08 * fi;
        float x = fract(t * (0.03 + 0.02 * hash11(fi)) + hash11(fi + 4.0)) * 2.4 - 1.2;
        x *= (mod(fi, 2.0) < 1.0 ? 1.0 : -1.0) * gfx_aspect() * 0.5;
        col += mix(GFX_ACCENT, vec3(1.0, 0.3, 0.2), mod(fi, 2.0)) * exp(-length((p - vec2(x, y)) * vec2(1.0, 3.0)) * 160.0) * 1.5;
    }
    // Low haze.
    col += GFX_PRIMARY * 0.12 * smoothstep(-0.2, -0.5, p.y) * fbm(vec2(p.x * 2.0 + t * 0.05, p.y * 4.0));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
