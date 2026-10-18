// @id liquid-surface
// @name Liquid Surface
// @category ocean
// @description A glossy, ink-dark liquid seen from above, slowly undulating while two lights slide across its reflective skin.
// @tags liquid, glossy, reflection, dark, elegant
// @mode background
// @uses gradient lighting
// @color PRIMARY #0D3B4F
// @color SECONDARY #03080C
// @color ACCENT #9EF0FF

float surf(vec2 p, float t) {
    return gnoise(p * 1.6 + vec2(t * 0.12, t * 0.05)) * 0.6
         + gnoise(p * 3.1 - vec2(t * 0.08, t * 0.15)) * 0.3
         + 0.15 * sin(length(p) * 6.0 - t * 0.8);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 2.0;
    float t = gfx_time();
    float e = 0.01;
    float h = surf(p, t);
    vec3 n = height_normal(h, surf(p + vec2(e, 0.0), t), surf(p + vec2(0.0, e), t), e, 0.35);
    vec3 v = vec3(0.0, 0.0, 1.0);

    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, 0.4 + 0.4 * h);
    // Two moving area lights reflected in the surface.
    for (int i = 0; i < 2; i++) {
        float fi = float(i);
        vec3 l = normalize(vec3(cos(t * 0.13 + fi * 3.0) * 0.8, sin(t * 0.17 + fi * 2.0) * 0.6, 1.0));
        col += GFX_ACCENT * pow(max(dot(reflect(-l, n), v), 0.0), 40.0 + fi * 60.0) * (0.9 - 0.4 * fi);
    }
    float fr = fresnel_schlick(n.z, 0.04);
    col += GFX_PRIMARY * fr * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
