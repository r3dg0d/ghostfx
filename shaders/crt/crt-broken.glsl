// @id crt-broken
// @name CRT Broken
// @category crt
// @description A dying monitor: misconverged colour guns, magnetised purity blotches, a dark band and the vertical hold slipping.
// @tags crt, broken, damaged, glitch, retro, horror
// @mode post
// @uses crt hash value fbm
// @flashing true
// @distorts true
// @param DAMAGE float 1.0 0.0 2.0 Overall damage level

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float D = P_DAMAGE * GFX_DISTORT_TEXT;

    // Vertical hold: occasionally the picture rolls a few lines.
    float slip = step(0.85, hash11(floor(t * 0.5))) * fract(t * 0.5) * 0.08 * D;
    vec2 suv = vec2(uv.x, fract(uv.y + slip));
    // Misconvergence grows toward the edges.
    vec2 c = suv - 0.5;
    vec2 off = c * dot(c, c) * 0.03 * P_DAMAGE + vec2(0.0015, 0.0) * P_DAMAGE;
    vec3 col = vec3(gfx_term(suv + off).r, gfx_term(suv).g, gfx_term(suv - off * vec2(1.0, -0.6)).b);
    vec4 term = gfx_term(uv);

    // Purity blotches from a magnetised shadow mask.
    vec2 q = uv * vec2(gfx_aspect(), 1.0) * 2.0;
    vec3 tint = vec3(fbm(q + 1.0), fbm(q + 7.0), fbm(q + 13.0));
    col *= mix(vec3(1.0), 0.6 + tint * 0.8, 0.35 * P_DAMAGE * smoothstep(0.2, 0.7, length(c)));
    // Rolling dark band and weak flicker.
    col *= 1.0 - 0.35 * P_DAMAGE * exp(-pow((fract(uv.y - t * 0.11) - 0.5) * 5.0, 2.0));
    col *= 1.0 + gfx_flash((vnoise(vec2(t * 9.0, 1.0)) - 0.5) * 0.12 * P_DAMAGE);
    col *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.4);
    col *= vignette(uv, 0.6);
    fragColor = gfx_post(term, col);
}
