// @id blue-fire
// @name Blue Fire
// @category fire
// @description A row of roaring gas-burner jets in electric blue, each with a white-cyan core and crackling tips.
// @tags fire, blue, gas, electric, cool
// @mode background
// @uses value hash
// @color PRIMARY #0A2BFF
// @color SECONDARY #00C8FF
// @color ACCENT #E8FDFF
// @param JETS float 14.0 4.0 30.0 Number of jets across a 16:9 screen
// @param HEIGHT float 0.35 0.1 0.8 Jet height (screen units)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    float w = 1.7778 / P_JETS;
    float id = floor(p.x / w);
    float lx = (fract(p.x / w) - 0.5) * w;
    float h = hash11(id + 3.0);
    float y = p.y + 0.5;
    float H = P_HEIGHT * (0.75 + 0.5 * h) * (0.85 + 0.15 * sin(t * 9.0 + h * 30.0));
    // Teardrop jet: wide at the base, flickering tip displaced by noise.
    float wob = (vnoise(vec2(id * 3.1, y * 8.0 - t * 6.0)) - 0.5) * 0.05 * y / H;
    float width = w * 0.42 * pow(max(1.0 - y / H, 0.0), 0.7) * smoothstep(-0.02, 0.03, y);
    float d = abs(lx - wob) / max(width, 1e-4);
    float body = smoothstep(1.0, 0.2, d) * step(0.0, y);
    float core = smoothstep(0.5, 0.0, d) * smoothstep(H * 0.6, 0.0, y);

    vec3 col = vec3(0.0, 0.01, 0.03);
    col += GFX_PRIMARY * body * 0.9;
    col += GFX_SECONDARY * body * smoothstep(H, 0.0, y) * 0.8;
    col += GFX_ACCENT * core;
    // Ambient glow from the burner line and crackle sparks.
    col += GFX_PRIMARY * 0.35 * exp(-y * 6.0);
    float sp = step(0.985, hash12(floor(vec2(p.x * 120.0, y * 60.0 - t * 30.0))));
    col += GFX_ACCENT * sp * smoothstep(H * 1.6, 0.0, y) * gfx_flash(0.6);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
