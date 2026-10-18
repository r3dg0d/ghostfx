// @id cyber-rain
// @name Cyber Rain
// @category cyberpunk
// @description Rain falls through neon light: streaks pick up pink and cyan from blurred signs, splashing on a wet reflective street.
// @tags rain, neon, cyberpunk, night, reflections
// @mode background
// @uses hash fbm
// @color PRIMARY #FF2E97
// @color SECONDARY #05060C
// @color ACCENT #19D9FF

vec3 signs(vec2 p) {
    vec3 c = vec3(0.0);
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        vec2 s = (hash22(vec2(fi, 2.0)) - 0.5) * vec2(gfx_aspect(), 0.5) + vec2(0.0, 0.15);
        vec3 sc = mod(fi, 2.0) < 1.0 ? GFX_PRIMARY : GFX_ACCENT;
        c += sc * 0.3 * exp(-length((p - s) * vec2(1.5, 3.0)) * 6.0);
    }
    return c;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float street = -0.3;
    vec3 col = GFX_SECONDARY + signs(p);
    // Wet street: mirrored, rippled sign light.
    if (p.y < street) {
        vec2 rp = vec2(p.x + 0.01 * sin(p.y * 120.0 + t * 3.0), 2.0 * street - p.y);
        col = GFX_SECONDARY * 0.8 + signs(rp) * 0.6 * smoothstep(-0.6, street, p.y);
        col += vec3(0.05) * fbm(vec2(p.x * 20.0, p.y * 60.0));
    }
    // Rain: thin streaks tinted by the light they pass through.
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        vec2 q = vec2(p.x * (90.0 + fi * 60.0), p.y * 3.0 + t * (5.0 + fi * 2.0) + fi * 3.0);
        vec2 id = floor(q);
        float h = hash12(id);
        float streak = step(0.92, h) * smoothstep(0.35, 0.0, abs(fract(q.x) - 0.5)) * smoothstep(0.0, 0.3, fract(q.y)) ;
        col += (vec3(0.25) + signs(p) * 2.0) * streak * (0.6 - fi * 0.2) * step(street, p.y);
    }
    // Splashes on the street line.
    vec2 sp = vec2(p.x * 60.0, t * 3.0);
    float splash = step(0.9, hash12(floor(sp))) * smoothstep(0.01, 0.0, abs(p.y - street)) * smoothstep(0.5, 0.0, abs(fract(sp.x) - 0.5));
    col += vec3(0.5) * splash;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
