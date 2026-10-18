// @id starfield
// @name Starfield
// @category space
// @description A calm flight through deep space: stars of different colours and depths slide past and grow as they approach.
// @tags space, stars, calm, classic, depth
// @mode background
// @uses hash
// @color PRIMARY #FFFFFF
// @color SECONDARY #02030A
// @color ACCENT #9DB8FF
// @param WARP float 0.15 0.0 1.0 Forward speed

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    const int N = 6;
    for (int i = 0; i < N; i++) {
        float fi = float(i);
        // Each layer cycles from far (z = 1) to near (z -> 0).
        float z = fract(fi / float(N) - t * P_WARP * 0.2);
        float fade = smoothstep(1.0, 0.7, z) * smoothstep(0.0, 0.15, z);
        vec2 q = p / max(z, 0.05) * 3.0 + fi * 37.0;
        vec2 id = floor(q);
        vec2 f = fract(q) - 0.5;
        vec2 o = (hash22(id) - 0.5) * 0.8;
        float h = hash12(id + 5.0);
        float d = length(f - o);
        float size = (0.02 + 0.03 * h) / max(z, 0.05) * 0.15;
        float star = smoothstep(size + 0.04, 0.0, d) * step(0.5, h);
        vec3 tint = mix(GFX_ACCENT, mix(GFX_PRIMARY, vec3(1.0, 0.8, 0.6), step(0.85, h)), h);
        col += tint * star * fade * (1.1 + 0.3 * sin(t * 3.0 + h * 50.0));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
