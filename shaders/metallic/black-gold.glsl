// @id black-gold
// @name Black and Gold
// @category metallic
// @description Art-deco luxury: fine gold sunburst and fan motifs inlaid in black lacquer, a warm sheen gliding across the gilt.
// @tags gold, black, art-deco, luxury, elegant, pattern
// @mode background
// @uses sdf
// @color PRIMARY #E8C26A
// @color SECONDARY #050403
// @color ACCENT #FFF0C2

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float px = 1.5 * gfx_pxsize();
    // Repeating fan tiles (scales pattern), each a set of concentric arcs and rays.
    vec2 g = p * vec2(3.2, 3.2);
    g.x += mod(floor(g.y), 2.0) * 0.5;
    vec2 id = floor(g);
    vec2 f = fract(g) - vec2(0.5, 0.0);
    float r = length(f);
    float a = atan(f.x, f.y);
    float lines = 0.0;
    lines += smoothstep(px * 2.5, 0.0, abs(r - 0.5)) * step(f.y, 0.5);
    lines += smoothstep(px * 2.5, 0.0, abs(r - 0.35)) * step(r, 0.5);
    lines += smoothstep(px * 2.5, 0.0, abs(r - 0.2)) * step(r, 0.5);
    lines += smoothstep(0.03, 0.0, abs(fract(a / 0.3927 + 0.5) - 0.5) * r) * step(r, 0.5) * step(0.2, r);
    float sheen = exp(-pow((p.x + p.y * 0.5) - (fract(t * 0.04) * 3.0 - 1.5) * gfx_aspect() * 0.7, 2.0) * 6.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * min(lines, 1.0) * (0.28 + 0.4 * sheen);
    col += GFX_ACCENT * min(lines, 1.0) * sheen * 0.3;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
