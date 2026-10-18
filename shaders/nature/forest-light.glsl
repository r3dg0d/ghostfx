// @id forest-light
// @name Forest Light
// @category nature
// @description Sunbeams slant down between tall trunks in a green forest, dust motes drifting slowly through the light.
// @tags forest, sunbeams, god-rays, green, nature, calm
// @mode background
// @uses value hash
// @color PRIMARY #FFE7A8
// @color SECONDARY #06120A
// @color ACCENT #2E5A2C

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.6, smoothstep(-0.5, 0.6, p.y));
    // Beams: bands in a slanted coordinate, gated by canopy gaps.
    vec2 dir = normalize(vec2(0.35, -1.0));
    float s = dot(p, vec2(-dir.y, dir.x));
    float beams = pow(vnoise(vec2(s * 9.0, t * 0.05)), 3.0) * 1.2 + pow(vnoise(vec2(s * 23.0 + 4.0, t * 0.08)), 4.0) * 0.6;
    beams *= smoothstep(-0.6, 0.5, p.y);
    col += GFX_PRIMARY * beams * 0.45;
    // Trunks at three depths.
    for (int i = 2; i >= 0; i--) {
        float fi = float(i);
        float w = 0.25 - fi * 0.06;
        float x = p.x + fi * 1.3;
        float id = floor(x / w);
        float h = hash11(id + fi * 7.0);
        float cx = (id + 0.3 + 0.4 * h) * w;
        float tw = (0.012 + 0.02 * hash11(id + 3.0)) * (1.0 + (2.0 - fi) * 0.6);
        float trunk = smoothstep(tw, tw * 0.8, abs(x - cx + 0.01 * sin(p.y * 6.0 + h * 10.0))) * step(0.35, h);
        vec3 tc = mix(vec3(0.02, 0.03, 0.02), GFX_ACCENT * 0.4, fi / 3.0);
        col = mix(col, tc, trunk);
    }
    // Dust motes catching the beams.
    vec2 g = p * 50.0 + vec2(sin(t * 0.2) * 2.0, -t * 0.4);
    vec2 id = floor(g);
    float mote = step(0.95, hash12(id)) * smoothstep(0.2, 0.0, length(fract(g) - 0.5));
    col += GFX_PRIMARY * mote * beams * 1.5;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
