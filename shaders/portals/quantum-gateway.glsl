// @id quantum-gateway
// @name Quantum Gateway
// @category portals
// @description Nested polygons rotate at quantised rates around a bright singular point, wrapped in shimmering interference fringes.
// @tags quantum, gateway, geometric, minimal, cyan, abstract
// @mode background
// @uses sdf
// @color PRIMARY #7DF9FF
// @color SECONDARY #020509
// @color ACCENT #FFFFFF

float sd_ngon(vec2 p, float r, float n) {
    float a = atan(p.y, p.x);
    float k = 6.2831 / n;
    float s = cos(floor(0.5 + a / k) * k - a) * length(p);
    return s - r;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.38, 0.0);
    float r = length(c);
    vec3 col = GFX_SECONDARY;
    float px = 1.5 * gfx_pxsize();
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        float n = 3.0 + fi;                              // triangle .. octagon
        float rot = t * 0.15 * (mod(fi, 2.0) < 1.0 ? 1.0 : -1.0) * (1.0 + fi * 0.2);
        float d = sd_ngon(gfx_rot(rot) * c, 0.05 + fi * 0.045, n);
        col += GFX_PRIMARY * smoothstep(px, 0.0, abs(d)) * (0.9 - fi * 0.1);
        col += GFX_PRIMARY * exp(-abs(d) * 90.0) * 0.08;
    }
    // Interference fringes radiating from two close foci.
    float f = sin(length(c - vec2(0.015, 0.0)) * 120.0 - t * 3.0) + sin(length(c + vec2(0.015, 0.0)) * 120.0 - t * 3.0);
    col += GFX_PRIMARY * f * f * 0.02 * smoothstep(0.4, 0.05, r);
    col += GFX_ACCENT * exp(-r * 40.0) * (0.8 + 0.2 * sin(t * 4.0));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
