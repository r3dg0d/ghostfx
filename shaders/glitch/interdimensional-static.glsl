// @id interdimensional-static
// @name Interdimensional Static
// @category glitch
// @description TV static from another dimension: chromatic snow in which fractal shapes keep surfacing and dissolving.
// @tags static, noise, surreal, glitch, colorful
// @mode background
// @uses hash fbm color
// @flashing true
// @color PRIMARY #9A7BFF
// @color SECONDARY #050407
// @color ACCENT #6BFFD5

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float frame = floor(t * (GFX_REDUCED_FLASH > 0.5 ? 6.0 : 30.0));
    vec2 cell = floor(fragCoord / max(gfx_dpi() * 2.0, 1.0));
    vec3 snow = vec3(hash12(cell + frame), hash12(cell + frame + 31.0), hash12(cell + frame + 57.0));
    // Shapes from "the other side" emerge through the noise.
    vec2 q;
    float shape = warped_fbm(p * 1.4, t * 0.3, q);
    float reveal = smoothstep(0.45, 0.75, shape);
    vec3 other = hsv2rgb(vec3(fract(q.x + t * 0.02), 0.6, 0.8));
    vec3 col = GFX_SECONDARY + snow * 0.18 * (1.0 - reveal * 0.6);
    col = mix(col, mix(GFX_PRIMARY, GFX_ACCENT, q.y) * 0.5 + other * 0.25, reveal * 0.7);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
