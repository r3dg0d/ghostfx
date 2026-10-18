// @id obsidian-gloss
// @name Obsidian Gloss
// @category metallic
// @description Polished volcanic glass: deep black with conchoidal ripple marks, catching a single slow gleam of light.
// @tags obsidian, black, glossy, dark, minimal, premium
// @mode background
// @uses gradient lighting
// @color PRIMARY #D8DCFF
// @color SECONDARY #020203
// @color ACCENT #4B3B6E

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Conchoidal fracture: concentric ripples around a few impact centres.
    float h = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(fi * 2.4) * 0.6, cos(fi * 1.7) * 0.3);
        float r = length(p - c);
        h += sin(r * (28.0 + fi * 6.0) + gnoise(p * 3.0 + fi) * 2.0) * exp(-r * 2.0) * 0.3;
    }
    float e = 0.004;
    vec2 g = vec2(dFdx(h), dFdy(h)) / max(gfx_pxsize(), 1e-5) * 0.03;
    vec3 n = normalize(vec3(-g, 1.0));
    vec3 l = normalize(vec3(cos(t * 0.1) * 0.7, 0.5, 0.8));
    float spec = blinn(n, l, vec3(0.0, 0.0, 1.0), 80.0);
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.05 * (0.5 + 0.5 * n.x);
    col += GFX_PRIMARY * spec * 1.2 + GFX_ACCENT * 0.25 * pow(1.0 - n.z, 0.5);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
