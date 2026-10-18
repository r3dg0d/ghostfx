// @id julia-set
// @name Julia Set
// @category geometric
// @description A Julia fractal that continually morphs as its parameter traces the edge of the Mandelbrot cardioid.
// @tags fractal, julia, math, morphing, colorful
// @mode background
// @uses color
// @color PRIMARY #3DE3FF
// @color SECONDARY #04040C
// @color ACCENT #FF4DA6

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // c on a path just outside the main cardioid: always interesting shapes.
    float a = t * 0.07;
    vec2 m = 0.5 * vec2(cos(a), sin(a)) - 0.25 * vec2(cos(2.0 * a), sin(2.0 * a));
    vec2 c = m * 1.02;
    vec2 z = (p - vec2(0.3, 0.0)) * 2.4;
    float n = 0.0;
    for (int i = 0; i < GFX_STEPS * 2; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 256.0) break;
        n += 1.0;
    }
    vec3 col = GFX_SECONDARY;
    if (n < float(GFX_STEPS * 2)) {
        float sn = n - log2(log2(dot(z, z))) + 4.0;
        float k = sn / float(GFX_STEPS * 2);
        col = mix(GFX_SECONDARY, mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.1, 0.5, k)), smoothstep(0.0, 0.25, k));
        col += vec3(1.0) * pow(k, 3.0) * 0.5;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
