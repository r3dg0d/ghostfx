// @id electric-purple
// @name Electric Purple
// @category electric
// @description Violet currents crawl sideways across the screen in braided bands, flaring wherever strands cross.
// @tags electric, purple, plasma, currents, neon
// @mode background
// @uses gradient
// @color PRIMARY #A64DFF
// @color SECONDARY #06020D
// @color ACCENT #FFB8FF
// @param BANDS int 5 2 10 Number of current bands

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    float acc = 0.0;
    for (int i = 0; i < P_BANDS; i++) {
        float fi = float(i);
        float y0 = (fi + 0.5) / float(P_BANDS) - 0.5;
        float wav = gnoise(vec2(p.x * 2.0 - t * (0.6 + fi * 0.1), fi * 3.0)) * 0.08 + gnoise(vec2(p.x * 9.0 - t * 2.0, fi * 7.0)) * 0.02;
        float d = abs(p.y - y0 - wav);
        float strand = exp(-d * 250.0) + exp(-d * 40.0) * 0.25;
        acc += strand;
    }
    col += GFX_PRIMARY * acc * 0.8;
    col += GFX_ACCENT * pow(max(acc - 1.0, 0.0), 2.0) * 0.6;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
