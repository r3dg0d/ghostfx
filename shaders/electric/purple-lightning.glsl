// @id purple-lightning
// @name Purple Lightning
// @category electric
// @description A violet storm where branching bolts crawl sideways across the whole sky, lighting the clouds magenta.
// @tags lightning, purple, storm, electric, dramatic
// @mode background
// @uses fbm hash sdf gradient
// @flashing true
// @color PRIMARY #D29BFF
// @color SECONDARY #07030E
// @color ACCENT #7A2EFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float clouds = fbm(vec2(p.x * 1.6 + t * 0.04, p.y * 2.5));
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.25, clouds);
    float light = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float per = 2.5 + fi;
        float slot = floor(t / per + fi * 0.3);
        float lt = fract(t / per + fi * 0.3) * per;
        float life = exp(-lt * 5.0) * step(0.35, hash11(slot * 1.7 + fi));
        float y0 = (hash11(slot + fi * 9.0) - 0.5) * 0.6;
        // Crawling bolt: mostly horizontal, jagged.
        float y = y0 + gnoise(vec2(p.x * 4.0, slot)) * 0.12 + gnoise(vec2(p.x * 16.0, slot + 3.0)) * 0.03;
        float reach = smoothstep(0.0, 0.25, lt) * gfx_aspect();
        float x0 = (hash11(slot + 2.0) - 0.5) * gfx_aspect();
        float on = step(abs(p.x - x0), reach);
        float d = abs(p.y - y);
        light += life;
        col += GFX_PRIMARY * (smoothstep(0.003, 0.0, d) + glow(d, 0.004) * 0.3) * on * gfx_flash(life) * 1.6;
    }
    col += GFX_PRIMARY * gfx_flash(min(light, 1.0)) * clouds * 0.3;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
