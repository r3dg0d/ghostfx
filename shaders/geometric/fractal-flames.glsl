// @id fractal-flames
// @name Fractal Flames
// @category geometric
// @description Wispy, luminous filaments in the style of fractal-flame art, woven by iterating swirl and sinusoidal variations.
// @tags fractal, flame, ifs, glow, colorful, abstract
// @mode background
// @uses color
// @color PRIMARY #FF7A2E
// @color SECONDARY #050307
// @color ACCENT #6E5BFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 2.2;
    float t = gfx_time() * 0.1;
    // Iterate a mix of flame "variations" and use orbit traps for density.
    vec2 z = p;
    float trap = 1e3, trap2 = 1e3, hueAcc = 0.0;
    for (int i = 0; i < GFX_STEPS / 4 + 6; i++) {
        float fi = float(i);
        float r2 = dot(z, z);
        vec2 swirl = vec2(z.x * sin(r2) - z.y * cos(r2), z.x * cos(r2) + z.y * sin(r2));
        vec2 sinus = sin(z * (1.3 + 0.2 * sin(t + fi)));
        z = mix(swirl, sinus, 0.5 + 0.4 * sin(t * 0.7 + fi * 0.3)) * 1.15 + vec2(0.2 * sin(t), 0.15 * cos(t * 1.3));
        trap = min(trap, abs(z.y - 0.1 * sin(z.x * 3.0 + t)));
        trap2 = min(trap2, length(z - vec2(0.3, -0.2)));
        hueAcc += exp(-trap * 30.0);
    }
    float f = exp(-trap * 18.0) * 1.2 + exp(-trap2 * 6.0) * 0.35;
    vec3 c = mix(GFX_ACCENT, GFX_PRIMARY, fract(hueAcc * 0.08));
    vec3 col = GFX_SECONDARY + tonemap_reinhard(c * f * 1.6);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
