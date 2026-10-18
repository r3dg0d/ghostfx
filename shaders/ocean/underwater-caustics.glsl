// @id underwater-caustics
// @name Underwater Caustics
// @category ocean
// @description Sunlight focused by a moving water surface into a bright, shifting net on a sandy pool floor.
// @tags ocean, water, caustics, pool, light, turquoise
// @mode background
// @uses voronoi gradient
// @color PRIMARY #0E7C86
// @color SECONDARY #06323C
// @color ACCENT #D9FFF8
// @param SCALE float 1.0 0.4 2.5 Caustic cell size
// @param DISPERSION float 1.0 0.0 2.0 Chromatic dispersion at quality ultra

// Bright where neighbouring Voronoi cells meet (F2 - F1 small); two layers
// multiplied give the characteristic interlocking caustic net.
float caustic(vec2 p, float t) {
    p += 0.45 * vec2(gnoise(p * 0.7 + t * 0.2), gnoise(p * 0.7 - t * 0.2 + 4.0));
    vec3 a = voronoi(p, t * 0.9);
    vec3 b = voronoi(p * 1.37 + 3.1, -t * 0.7);
    float ca = 1.0 - smoothstep(0.0, 0.1, a.y - a.x);
    float cb = 1.0 - smoothstep(0.0, 0.12, b.y - b.x);
    return pow(ca, 3.0) * 0.55 + pow(cb, 3.0) * 0.35 + ca * cb * 1.2;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 5.0 / P_SCALE;
    float t = gfx_time() * 0.8;

    vec3 floorc = mix(GFX_SECONDARY, GFX_PRIMARY, 0.55 + 0.25 * gnoise(p * 0.3));
#if GFX_QUALITY >= 2
    float o = 0.04 * P_DISPERSION;
    vec3 light = vec3(caustic(p + vec2(o, 0.0), t), caustic(p, t), caustic(p - vec2(o, 0.0), t));
#else
    vec3 light = vec3(caustic(p, t));
#endif
    vec3 col = floorc + GFX_ACCENT * light * 0.75;
    col *= 0.85 + 0.15 * sin(gfx_p(fragCoord).x * 3.0 + t * 0.3);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
