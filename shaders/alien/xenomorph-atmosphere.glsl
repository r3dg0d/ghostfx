// @id xenomorph-atmosphere
// @name Xenomorph Atmosphere
// @category alien
// @description A dark, wet biomechanical hive: ribbed walls glisten in the gloom and slowly breathe.
// @tags alien, dark, horror, biomechanical, organic
// @mode background
// @uses fbm lighting
// @color PRIMARY #1C2B22
// @color SECONDARY #030504
// @color ACCENT #8FB5A0

float ribs(vec2 p, float t) {
    vec2 w = p + 0.25 * vec2(fbm(p * 1.5), fbm(p * 1.5 + 4.0));
    float r = sin(w.y * 22.0 + sin(w.x * 3.0) * 2.0);
    float breathe = 0.04 * sin(t * 0.6);
    return pow(0.5 + 0.5 * r, 3.0) * (0.7 + 0.3 * fbm(w * 4.0)) + breathe * w.x;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.3;
    float t = gfx_time();
    float e = 0.004;
    float h = ribs(p, t);
    vec3 n = height_normal(h, ribs(p + vec2(e, 0.0), t), ribs(p + vec2(0.0, e), t), e, 0.06);
    vec3 l = normalize(vec3(0.3 * sin(t * 0.2), 0.6, 0.8));
    float diff = max(dot(n, l), 0.0);
    float spec = pow(max(dot(reflect(-l, n), vec3(0.0, 0.0, 1.0)), 0.0), 60.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * diff * h * 1.2 + GFX_ACCENT * spec * 0.6;
    col *= 0.6 + 0.4 * smoothstep(1.2, 0.0, length(p));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
