// @id nebula
// @name Nebula
// @category space
// @description Billowing clouds of glowing gas in magenta, teal and gold, laced with dark dust and embedded young stars.
// @tags space, nebula, colorful, clouds, cosmic
// @mode background
// @uses fbm hash
// @color PRIMARY #FF4FA0
// @color SECONDARY #03020A
// @color ACCENT #33D6C8

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.6;
    float t = gfx_time() * 0.05;
    vec2 q;
    float n = warped_fbm(p, t, q);
    float dust = smoothstep(0.45, 0.75, fbm(p * 2.5 + q * 2.0 + 8.0));
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * pow(n, 2.0) * 0.9;
    col += GFX_ACCENT * pow(q.y, 3.0) * 0.8;
    col += vec3(1.0, 0.8, 0.5) * pow(n * q.x, 4.0) * 1.5;
    col *= 1.0 - dust * 0.7;
    vec2 g = gfx_p(fragCoord) * 90.0;
    vec2 id = floor(g);
    float h = hash12(id);
    col += vec3(0.95) * step(0.985, h) * smoothstep(0.35, 0.0, length(fract(g) - 0.5)) * (0.6 + 0.4 * sin(gfx_time() * 2.0 + h * 40.0));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
