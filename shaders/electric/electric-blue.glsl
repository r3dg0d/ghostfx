// @id electric-blue
// @name Electric Blue
// @category electric
// @description A field of thin, writhing blue energy filaments that crackle across the whole background.
// @tags electric, blue, energy, filaments, field
// @mode background
// @uses fbm
// @color PRIMARY #3D8BFF
// @color SECONDARY #01040C
// @color ACCENT #CFE6FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 2.0;
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 q = p * (1.0 + fi * 0.6) + vec2(t * 0.15 * (fi + 1.0), -t * 0.1);
        q += 0.4 * vec2(fbm(q + t * 0.3), fbm(q - t * 0.3 + 5.0));
        float r = ridged(q);
        float fil = pow(r, 8.0 + fi * 4.0);
        col += mix(GFX_PRIMARY, GFX_ACCENT, fil) * fil * (1.0 - fi * 0.25);
    }
    col += GFX_PRIMARY * 0.05;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
