// @id liquid-glass
// @name Liquid Glass
// @category glass
// @description Blobs of clear liquid glass drift and merge over the terminal, magnifying what lies beneath with bright refractive rims.
// @tags glass, liquid, refraction, lens, modern, glossy
// @mode glow
// @uses sdf crt
// @distorts true
// @color PRIMARY #9FE7FF
// @color SECONDARY #0D1018
// @color ACCENT #FFFFFF
// @param MAGNIFY float 0.25 0.0 0.6 Magnification inside the glass
// @param BLOBS int 4 1 7 Number of glass blobs
// @preset subtle MAGNIFY=0.1

float glass_sdf(vec2 p, float t) {
    float d = 1e3;
    for (int i = 0; i < P_BLOBS; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * 0.11 + fi * 2.3) * 0.65, cos(t * 0.09 + fi * 1.7) * 0.3) * vec2(gfx_aspect() * 0.55, 1.0);
        d = smin(d, length(p - c) - (0.1 + 0.04 * sin(fi * 3.0 + t * 0.2)), 0.12);
    }
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float d = glass_sdf(p, t);
    float e = 0.003;
    vec2 n = vec2(glass_sdf(p + vec2(e, 0.0), t) - d, glass_sdf(p + vec2(0.0, e), t) - d) / e;
    float inside = smoothstep(0.004, -0.004, d);
    // Lens: magnify toward the blob centre, strongest deep inside.
    float depth = clamp(-d / 0.12, 0.0, 1.0);
    // Magnify about the blob centre: the SDF gradient points away from it and
    // the distance to it is roughly (radius + d).
    vec2 toCentre = -n * max(0.12 + d, 0.0) * P_MAGNIFY * inside;
    vec2 suv = uv + gfx_text_offset(toCentre / vec2(gfx_aspect(), 1.0)) / max(GFX_INTENSITY, 1e-3);
    vec4 term = gfx_term(suv);
    // Dispersion on the rim.
    vec3 fx = GFX_SECONDARY + GFX_PRIMARY * (0.1 + 0.08 * (1.0 - depth)) * inside;
    float rim = exp(-abs(d) * 220.0);
    float spec = pow(max(dot(normalize(n + 1e-4), normalize(vec2(-0.6, 0.8))), 0.0), 8.0) * rim;
    vec3 light = GFX_PRIMARY * rim * 0.35 + GFX_ACCENT * spec * 0.7;
    light += vec3(1.0, 0.3, 0.6) * exp(-abs(d + 0.006) * 300.0) * 0.12 + vec3(0.3, 0.8, 1.0) * exp(-abs(d - 0.006) * 300.0) * 0.12;
    fragColor = gfx_compose_glow(uv, term, fx, light);
}
