// @id warp-speed
// @name Warp Speed
// @category space
// @description The jump to hyperspace: star streaks stretch radially from a bright vanishing point and rush past the edges.
// @tags space, warp, hyperspace, speed, blue
// @mode background
// @uses hash
// @color PRIMARY #BFD8FF
// @color SECONDARY #01030A
// @color ACCENT #6A8CFF
// @param SPEED_WARP float 1.0 0.2 3.0 Streak speed
// @param STREAKS float 220.0 60.0 600.0 Number of angular streak lanes

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float r = length(p);
    float a = atan(p.y, p.x);
    float lanes = floor(P_STREAKS);
    float lane = floor((a / 6.2831 + 0.5) * lanes);
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.25 * exp(-r * 4.0);
    for (int k = 0; k < 2; k++) {
        float fk = float(k);
        float h = hash12(vec2(lane, fk));
        float speed = (0.4 + h) * P_SPEED_WARP;
        // Streak head position in 1/r space so motion accelerates outward.
        float z = fract(h * 7.0 + t * speed * 0.25);
        float head = 0.05 + z * z * 1.4;
        float len = 0.02 + z * 0.35;
        float along = smoothstep(head - len, head, r) * step(r, head);
        float la = fract((a / 6.2831 + 0.5) * lanes) - 0.5;
        float width = smoothstep(0.5, 0.0, abs(la)) ;
        float on = step(0.45, hash12(vec2(lane, fk + 9.0)));
        col += mix(GFX_ACCENT, GFX_PRIMARY, z) * along * width * on * (0.4 + z) * 1.2;
    }
    col += GFX_PRIMARY * 0.4 * exp(-r * 25.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
