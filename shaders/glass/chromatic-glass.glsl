// @id chromatic-glass
// @name Chromatic Glass
// @category glass
// @description A wall of thick glass bricks: each block bends the light behind it and splits its edges into rainbow fringes.
// @tags glass, bricks, chromatic, dispersion, refraction
// @mode background
// @uses sdf value
// @distorts true
// @color PRIMARY #FF6BB5
// @color SECONDARY #090A10
// @color ACCENT #6BD6FF
// @param BRICKS float 6.0 3.0 14.0 Bricks per screen height

vec3 backdrop(vec2 q, float t) {
    vec3 c = vec3(0.0);
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        vec2 b = vec2(sin(t * 0.1 + fi * 2.0) * 0.6, cos(t * 0.08 + fi * 1.4) * 0.3);
        vec3 bc = i == 0 ? GFX_PRIMARY : i == 1 ? GFX_ACCENT : vec3(1.0, 0.85, 0.4);
        c += bc * 0.4 * exp(-dot(q - b, q - b) * 8.0);
    }
    return c;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 g = p * P_BRICKS;
    g.x += mod(floor(g.y), 2.0) * 0.5;               // running bond
    vec2 f = fract(g) - 0.5;
    float d = sd_box(f, vec2(0.46, 0.44)) - 0.03;
    // Pillowed brick surface: refraction grows toward the edges.
    vec2 bend = f * pow(length(f) * 2.0, 2.0) * 0.08;
    vec3 col = GFX_SECONDARY;
    col.r += backdrop(p - bend * 1.2, t).r;
    col.g += backdrop(p - bend, t).g;
    col.b += backdrop(p - bend * 0.8, t).b;
    col += vec3(0.05) * smoothstep(0.0, -0.05, d) * (0.5 - f.y);
    col = mix(col, GFX_SECONDARY * 0.6, smoothstep(-0.01, 0.01, d));   // mortar
    fragColor = gfx_compose(uv, gfx_term(uv + gfx_text_offset(bend * 0.02)), col);
}
