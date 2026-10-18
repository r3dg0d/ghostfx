// @id glowing-runes
// @name Glowing Runes
// @category portals
// @description A magic circle of rotating rune rings and a hexagram glows on the ground, symbols igniting one after another.
// @tags runes, magic, circle, summoning, fantasy, glow
// @mode background
// @uses hash sdf
// @color PRIMARY #FFB347
// @color SECONDARY #070403
// @color ACCENT #FF5E3A

float rune_glyph(vec2 f, float seed) {
    if (abs(f.x) > 1.0 || abs(f.y) > 1.0) return 1e3;
    float d = 1e3;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 a = (hash22(vec2(seed, fi)) - 0.5) * 1.6;
        vec2 b = (hash22(vec2(seed, fi + 5.0)) - 0.5) * 1.6;
        d = min(d, sd_segment(f, a, b));
    }
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = (p - vec2(0.42, -0.05)) * vec2(1.0, 1.6);           // seen at an angle
    float r = length(c);
    float px = 2.0 * gfx_pxsize();
    vec3 col = GFX_SECONDARY;
    float lines = smoothstep(px, 0.0, abs(r - 0.3)) + smoothstep(px, 0.0, abs(r - 0.22)) + smoothstep(px, 0.0, abs(r - 0.12));
    // Hexagram from two triangles.
    vec2 hq = gfx_rot(t * 0.05) * c;
    lines += smoothstep(px, 0.0, abs(sd_triangle(hq, 0.12)));
    lines += smoothstep(px, 0.0, abs(sd_triangle(-hq, 0.12)));
    // Rune ring between r = 0.22 and 0.3, rotating; runes ignite in sequence.
    float a = atan(c.y, c.x) + t * 0.1;
    float n = 24.0;
    float seg = floor((a / 6.2831 + 0.5) * n);
    float fa = fract((a / 6.2831 + 0.5) * n) - 0.5;
    vec2 f = vec2(fa * 2.2, (r - 0.26) / 0.03);
    float g = rune_glyph(f, seg);
    float ignite = smoothstep(0.0, 0.5, fract(t * 0.15 - seg / n));
    col += GFX_PRIMARY * min(lines, 1.0) * 0.7;
    col += mix(GFX_ACCENT, GFX_PRIMARY, ignite) * smoothstep(0.15, 0.05, g) * (0.3 + 0.7 * ignite);
    col += GFX_ACCENT * 0.08 * exp(-r * 4.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
