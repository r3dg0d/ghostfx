// @id rainbow-chrome
// @name Rainbow Chrome
// @category metallic
// @description Holographic foil: a mirror-bright surface whose rippled reflections cycle through every colour of the rainbow.
// @tags chrome, rainbow, holographic, foil, iridescent
// @mode background
// @uses gradient color lighting

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.5;
    float t = gfx_time();
    float e = 0.01;
    float h = gnoise(p * 2.0 + t * 0.05) + 0.4 * gnoise(p * 5.0);
    float hx = gnoise((p + vec2(e, 0.0)) * 2.0 + t * 0.05) + 0.4 * gnoise((p + vec2(e, 0.0)) * 5.0);
    float hy = gnoise((p + vec2(0.0, e)) * 2.0 + t * 0.05) + 0.4 * gnoise((p + vec2(0.0, e)) * 5.0);
    vec3 n = height_normal(h, hx, hy, e, 0.25);
    vec3 r = reflect(vec3(0.0, 0.0, -1.0), n);
    // Diffraction-foil look: hue from reflection direction, brightness from a chrome env.
    vec3 hue = hsv2rgb(vec3(fract(r.x * 1.5 + r.y + t * 0.03), 0.8, 1.0));
    float chrome = smoothstep(-0.2, 0.3, r.y) * 0.6 + pow(max(r.x, 0.0), 4.0) * 0.6;
    vec3 col = hue * (0.1 + chrome * 0.4);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
