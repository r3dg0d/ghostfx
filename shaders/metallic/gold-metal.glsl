// @id gold-metal
// @name Gold Metal
// @category metallic
// @description Softly undulating polished gold, its warm reflections and crisp highlights rolling as the light moves.
// @tags gold, metal, luxury, warm, glossy
// @mode background
// @uses gradient lighting sdf
// @color PRIMARY #F5C451
// @color SECONDARY #2A1A05
// @color ACCENT #FFF3C9

float gold_h(vec2 p, float t) {
    return gnoise(p * 1.4 + t * 0.03) * 0.5 + gnoise(p * 2.7 - t * 0.02) * 0.25;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 1.5;
    float t = gfx_time();
    float e = 0.01;
    float h = gold_h(p, t);
    vec3 n = height_normal(h, gold_h(p + vec2(e, 0.0), t), gold_h(p + vec2(0.0, e), t), e, 0.35);
    vec3 r = reflect(vec3(0.0, 0.0, -1.0), n);
    // Two softbox lights reflected in the gently undulating surface: their
    // warped crisp shapes are what reads as "polished".
    vec2 rr = p * 0.7 + r.xy * 0.7 + vec2(0.15 * sin(t * 0.07), 0.0);
    float box1 = smoothstep(0.06, 0.0, sd_box(rr - vec2(-0.45, 0.35), vec2(0.3, 0.12)));
    float box2 = smoothstep(0.08, 0.0, sd_box(rr - vec2(0.55, -0.1), vec2(0.08, 0.45)));
    float env = box1 + box2 * 0.7 + 0.15 * smoothstep(-0.6, 0.6, rr.y);
    vec3 col = GFX_PRIMARY * (0.1 + env * 0.95) + GFX_ACCENT * pow(env, 3.0) * 0.4;
    vec3 l = normalize(vec3(cos(t * 0.2), sin(t * 0.15), 1.0));
    col += GFX_ACCENT * blinn(n, l, vec3(0.0, 0.0, 1.0), 120.0) * 0.8;
    col = mix(GFX_SECONDARY, col, 0.85);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
