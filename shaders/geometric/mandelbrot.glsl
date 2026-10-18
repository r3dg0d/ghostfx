// @id mandelbrot
// @name Mandelbrot
// @category geometric
// @description The whole Mandelbrot set, smoothly shaded, with colour bands flowing outward from its boundary.
// @tags fractal, mandelbrot, math, classic, colorful
// @mode background
// @uses color
// @color PRIMARY #7D5CFF
// @color SECONDARY #04030A
// @color ACCENT #FFC14D
// @param X float 0.35 -0.8 0.8 Set position on screen

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = (p - vec2(P_X, 0.0)) * 2.6 + vec2(-0.6, 0.0);
    vec2 z = vec2(0.0);
    float n = 0.0;
    float trap = 1e3;
    for (int i = 0; i < GFX_STEPS * 2; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, abs(z.x * z.y));
        if (dot(z, z) > 256.0) break;
        n += 1.0;
    }
    vec3 col;
    if (n >= float(GFX_STEPS * 2)) {
        col = GFX_SECONDARY + GFX_PRIMARY * 0.15 * exp(-trap * 20.0);
    } else {
        float sn = n - log2(log2(dot(z, z))) + 4.0;
        float k = sqrt(sn) * 0.3 - t * 0.08;
        col = mix(GFX_PRIMARY, GFX_ACCENT, 0.5 + 0.5 * sin(k * 6.2831)) * smoothstep(0.0, 6.0, sn) * 0.9;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
