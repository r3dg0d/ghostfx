// @id biomechanical
// @name Biomechanical
// @category alien
// @description Tangled tubes of bone and bronze knotted into a single surface, lit by a slow-moving lamp.
// @tags alien, biomechanical, metal, organic, bronze
// @mode background
// @uses fbm lighting
// @color PRIMARY #8A6A3A
// @color SECONDARY #050403
// @color ACCENT #E8D2A0

float tubes(vec2 p) {
    vec2 q = p + 0.4 * vec2(fbm(p * 0.8), fbm(p * 0.8 + 3.3));
    float r = ridged(q * 1.2);
    float v = 1.0 - abs(sin(q.x * 4.0 + fbm(q * 2.0) * 3.0));
    return r * 0.7 + pow(v, 4.0) * 0.4;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 2.0;
    float t = gfx_time();
    p += vec2(t * 0.02, 0.0);
    float e = 0.01;
    float h = tubes(p);
    vec3 n = height_normal(h, tubes(p + vec2(e, 0.0)), tubes(p + vec2(0.0, e)), e, 0.12);
    vec3 l = normalize(vec3(cos(t * 0.25), sin(t * 0.25), 0.9));
    float diff = max(dot(n, l), 0.0);
    float spec = pow(max(dot(reflect(-l, n), vec3(0.0, 0.0, 1.0)), 0.0), 24.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * diff * h + GFX_ACCENT * spec * h * 0.8;
    col *= 0.5 + h;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
