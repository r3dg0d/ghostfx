// @id solar-flare
// @name Solar Flare
// @category fire
// @description The boiling limb of a star rises from the bottom edge, its granulated surface throwing looping plasma prominences.
// @tags sun, plasma, space, fire, orange, dramatic
// @mode background
// @uses fbm voronoi hash
// @color PRIMARY #FF4E00
// @color SECONDARY #2A0700
// @color ACCENT #FFF1B8

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec2 c = vec2(0.0, -1.62);
    float R = 1.45;
    vec2 d = p - c;
    float r = length(d);
    float a = atan(d.y, d.x);
    vec3 col = GFX_SECONDARY * 0.3;

    if (r < R) {
        vec3 g = voronoi(vec2(a * 40.0, r * 25.0), t * 0.6);
        float gran = smoothstep(0.0, 0.5, g.y - g.x);
        float boil = fbm(vec2(a * 12.0, r * 6.0) + t * 0.15);
        col = mix(GFX_PRIMARY * 0.8, GFX_ACCENT, gran * 0.5 + boil * 0.4);
        col *= mix(0.55, 1.0, smoothstep(R - 0.5, R, r) * 0.0 + smoothstep(0.0, 0.25, R - r));
    } else {
        float hgt = r - R;
        // Corona.
        col += GFX_PRIMARY * 0.7 * exp(-hgt * 9.0);
        // Prominences: arches anchored on the limb, rising and fading.
        for (int k = 0; k < 4; k++) {
            float fk = float(k);
            float life = fract(t * 0.03 + fk * 0.27);
            float ac = 1.5708 + (fk - 1.5) * 0.28 + 0.05 * sin(t * 0.1 + fk);
            float w = 0.05 + 0.04 * hash11(fk + floor(t * 0.03 + fk * 0.27));
            float s = (a - ac) / w;
            float H = (0.08 + 0.18 * hash11(fk * 3.0 + 1.0)) * smoothstep(0.0, 0.3, life);
            float arch = H * sqrt(max(1.0 - s * s, 0.0));
            float fil = fbm(vec2(s * 4.0 + fk * 7.0, hgt * 30.0 - t * 0.6));
            float dd = abs(hgt - arch) - 0.006 - 0.012 * fil;
            float prom = exp(-max(dd, 0.0) * 120.0) * step(abs(s), 1.0) * (1.0 - smoothstep(0.7, 1.0, life));
            col += mix(GFX_PRIMARY, GFX_ACCENT, fil * 0.8) * prom * (0.7 + 0.6 * fil);
        }
        col += GFX_PRIMARY * 0.3 * pow(fbm(vec2(a * 6.0 - t * 0.05, hgt * 4.0 - t * 0.3)), 3.0) * exp(-hgt * 4.0);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
