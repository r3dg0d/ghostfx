// @id test-pattern
// @name Test Pattern
// @category crt
// @description An analog broadcast test card glowing faintly behind the text: colour bars, a grey ramp, a convergence grid and a centring circle.
// @tags test-pattern, broadcast, retro, tv, bars
// @mode background
// @uses sdf color
// @animated false

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = vec3(0.12);
    // Seven colour bars across the upper two thirds.
    if (uv.y > 0.33) {
        float bi = floor(uv.x * 7.0);
        vec3 bars[7];
        bars[0] = vec3(0.75); bars[1] = vec3(0.75, 0.75, 0.0); bars[2] = vec3(0.0, 0.75, 0.75);
        bars[3] = vec3(0.0, 0.75, 0.0); bars[4] = vec3(0.75, 0.0, 0.75); bars[5] = vec3(0.75, 0.0, 0.0); bars[6] = vec3(0.0, 0.0, 0.75);
        col = bars[int(bi)];
    } else if (uv.y > 0.25) {
        col = vec3(floor(uv.x * 10.0) / 9.0) * 0.8;               // grey steps
    }
    // Convergence grid and centre circle on top.
    float grid = grid_lines(p * 12.0, 1.0);
    col = mix(col, vec3(1.0), grid * 0.35);
    col = mix(col, vec3(1.0), smoothstep(0.003, 0.0, abs(length(p) - 0.33)) * 0.8);
    col = mix(col, vec3(0.0), smoothstep(0.003, 0.0, abs(p.x)) * step(abs(p.y), 0.05));
    col = mix(col, vec3(0.0), smoothstep(0.003, 0.0, abs(p.y)) * step(abs(p.x), 0.05));
    col *= 0.38;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
