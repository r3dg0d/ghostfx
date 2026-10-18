// @id broken-gpu
// @name Broken GPU
// @category glitch
// @description Simulated driver meltdown: stretched texture stripes, checkerboard tiles and spiky wrong-colour polygons that come and go.
// @tags glitch, gpu, artifacts, corruption, chaotic
// @mode post
// @uses hash sdf
// @flashing true
// @distorts true
// @param CHAOS float 0.35 0.0 1.0 Amount of corruption on screen
// @preset subtle CHAOS=0.12

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float era = floor(t * 1.5);
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(term);
    float D = P_CHAOS * GFX_DISTORT_TEXT * GFX_INTENSITY;

    // Stretched stripes: a column's pixels repeat one source row.
    float colId = floor(uv.x * 40.0);
    float stretch = step(1.0 - 0.25 * D, hash12(vec2(colId, era)));
    float srcY = hash12(vec2(colId, era + 1.0));
    col = mix(col, gfx_straight(gfx_term(vec2(uv.x, srcY))), stretch);
    // Checkerboard tiles.
    vec2 tile = floor(fragCoord / (48.0 * gfx_dpi()));
    float chk = step(1.0 - 0.06 * D, hash12(tile + era * 3.0));
    float pat = mod(floor(fragCoord.x / (4.0 * gfx_dpi())) + floor(fragCoord.y / (4.0 * gfx_dpi())), 2.0);
    col = mix(col, mix(vec3(1.0, 0.0, 1.0), vec3(0.0), pat), chk * 0.85);
    // Spiky polygons: thin triangles in garish colours.
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        if (hash11(era * 7.0 + fi) > D) continue;
        vec2 c = (hash22(vec2(era, fi)) - 0.5) * vec2(gfx_aspect(), 1.0);
        vec2 q = gfx_rot(hash11(fi + era) * 6.28) * (p - c);
        q.x *= 0.15 + 0.3 * hash11(fi * 3.0 + era);
        float tri = step(sd_triangle(q, 0.12), 0.0);
        col = mix(col, vec3(hash11(fi + era * 2.0), hash11(fi + 9.0), hash11(era - fi)), tri * gfx_flash(1.0));
    }
    fragColor = gfx_post_k(term, col, 1.0);
}
