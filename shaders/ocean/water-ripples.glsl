// @id water-ripples
// @name Water Ripples
// @category ocean
// @description Raindrop-like ripples bloom at random points on a dark, still pond and spread out in widening rings.
// @tags water, ripples, pond, calm, minimal
// @mode background
// @uses hash
// @distorts true
// @color PRIMARY #12324A
// @color SECONDARY #050D16
// @color ACCENT #A8DDF2
// @param SOURCES int 6 1 10 Simultaneous ripple sources
// @param PERIOD float 4.0 1.5 10.0 Seconds between drops per source

float ripples(vec2 p, float t) {
    float h = 0.0;
    for (int i = 0; i < P_SOURCES; i++) {
        float fi = float(i);
        float lt = t + fi * P_PERIOD / float(P_SOURCES);
        float cyc = floor(lt / P_PERIOD);
        float age = lt - cyc * P_PERIOD;
        vec2 c = (hash22(vec2(fi, cyc)) - 0.5) * vec2(gfx_aspect(), 1.0) * 0.95;
        float r = length(p - c);
        float front = age * 0.22;
        float x = r - front;
        h += sin(x * 70.0) * exp(-x * x * 160.0) * exp(-age * 0.7) / (1.0 + r * 6.0);
    }
    return h;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float e = 2.0 / iResolution.y;
    float h = ripples(p, t);
    vec2 g = vec2(ripples(p + vec2(e, 0.0), t) - h, ripples(p + vec2(0.0, e), t) - h) / e;
    vec3 n = normalize(vec3(-g * 0.012, 1.0));

    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, smoothstep(-0.7, 0.6, p.y + n.y * 2.0));
    float spec = pow(max(dot(reflect(vec3(0.0, 0.0, -1.0), n.xzy), normalize(vec3(0.4, 0.7, 0.3))), 0.0), 24.0);
    col += GFX_ACCENT * (spec * 0.9 + abs(n.x + n.y) * 0.6);

    vec4 term = gfx_term(uv + gfx_text_offset(n.xy * 0.01));
    fragColor = gfx_compose(uv, term, col);
}
