// @id pixel-sort
// @name Pixel Sort
// @category glitch
// @description Glitch-art pixel sorting: bright runs of the image melt downward in streaks, the smear length breathing over time.
// @tags pixel-sort, glitch-art, melt, streaks, databending
// @mode post
// @uses hash
// @distorts true
// @param LENGTH float 0.06 0.01 0.4 Maximum streak length (fraction of height)
// @param THRESHOLD float 0.5 0.1 0.9 Brightness that starts a streak
// @preset subtle LENGTH=0.025
// @preset cinematic LENGTH=0.18

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);
    vec3 col = gfx_straight(term);
    // Approximate sorting: carry the brightest pixel found above downward,
    // fading with distance. Columns get their own run length.
    float colId = floor(fragCoord.x / max(gfx_dpi(), 1.0));
    float len = P_LENGTH * (0.3 + 0.7 * hash11(colId * 0.37)) * (0.6 + 0.4 * sin(t * 0.5 + colId * 0.01)) * GFX_DISTORT_TEXT * GFX_INTENSITY;
    float bgl = gfx_luma(GFX_TERM_BG);
    const int N = 16;
    for (int i = 1; i <= N; i++) {
        float k = float(i) / float(N);
        vec3 s = gfx_straight(gfx_term(uv + vec2(0.0, k * len)));
        float bright = gfx_luma(s) - bgl;
        float w = step(P_THRESHOLD * (1.0 - bgl), bright) * (1.0 - k);
        col = mix(col, s, w * 0.85);
    }
    fragColor = gfx_post_k(term, col, 1.0);
}
