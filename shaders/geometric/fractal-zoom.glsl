// @id fractal-zoom
// @name Fractal Zoom
// @category geometric
// @description An endless dive into the Mandelbrot set's Seahorse Valley, spirals unfolding into ever-smaller spirals.
// @tags fractal, mandelbrot, zoom, infinite, math
// @mode background
// @uses color
// @color PRIMARY #FF8A3D
// @color SECONDARY #05030C
// @color ACCENT #3D9BFF
// @param CYCLE float 30.0 10.0 120.0 Seconds per zoom cycle
// @limitation 32-bit floats limit the zoom depth; the dive loops every cycle with a cross-fade.

vec3 mandel(vec2 c) {
    vec2 z = vec2(0.0);
    float n = 0.0;
    const float B = 64.0;
    for (int i = 0; i < GFX_STEPS * 3; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > B * B) break;
        n += 1.0;
    }
    if (n >= float(GFX_STEPS * 3)) return GFX_SECONDARY;
    float sn = n - log2(log2(dot(z, z))) + 4.0;          // smooth iteration count
    float k = sn * 0.035;
    return mix(GFX_ACCENT, GFX_PRIMARY, 0.5 + 0.5 * cos(k * 6.2831)) * (0.35 + 0.65 * fract(k * 2.0 + 0.5));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float ph = fract(t / P_CYCLE);
    float zoom = exp(-ph * 9.0) * 1.6;
    vec2 center = vec2(-0.743643887, 0.131825904);
    vec3 col = mandel(center + gfx_rot(ph * 1.5) * p * zoom);
    col *= smoothstep(0.0, 0.05, ph) * smoothstep(1.0, 0.92, ph);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
