// @id electric-storm
// @name Electric Storm
// @category electric
// @description Towering storm clouds flicker from within as sheet lightning crawls through them, over driving rain.
// @tags storm, lightning, clouds, rain, dramatic
// @mode background
// @uses fbm hash
// @flashing true
// @color PRIMARY #B9C9FF
// @color SECONDARY #07080F
// @color ACCENT #6A4CB0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 q = vec2(p.x * 1.5 + t * 0.03, p.y * 2.0);
    float dens = fbm(q + 0.5 * fbm(q * 2.0 - t * 0.05));
    // Several internal flash sources that light nearby cloud mass.
    float light = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float slot = floor(t * 1.3 + fi * 0.33);
        float lt = fract(t * 1.3 + fi * 0.33);
        vec2 c = (hash22(vec2(slot, fi)) - 0.5) * vec2(gfx_aspect(), 0.6) + vec2(0.0, 0.15);
        float on = step(0.6, hash11(slot * 3.1 + fi));
        light += on * exp(-lt * 8.0) * exp(-length(p - c) * 4.0) * (0.6 + 0.4 * sin(lt * 60.0));
    }
    light = gfx_flash(light);
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.35, dens);
    col += GFX_PRIMARY * light * dens * 1.6;
    // Sheet-lightning filaments inside the clouds.
    float fil = pow(ridged(q * 3.0 + t * 0.2), 10.0) * light;
    col += GFX_PRIMARY * fil * 2.0;
    vec2 rq = vec2(p.x + p.y * 0.15, p.y) * vec2(120.0, 2.5) + vec2(0.0, t * 10.0);
    col += vec3(0.5, 0.55, 0.7) * step(0.95, hash12(floor(rq))) * 0.15;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
