// @id green-fire
// @name Green Fire
// @category fire
// @description Supernatural green flames creep in from every edge of the window, curling into ghostly wisps.
// @tags fire, green, ghostly, supernatural, frame
// @mode background
// @uses fbm
// @color PRIMARY #0B3D0B
// @color SECONDARY #3DFF6E
// @color ACCENT #E6FFD9
// @param REACH float 0.22 0.08 0.5 How far flames reach in from the edges

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    // Distance to the nearest window edge, in screen-height units.
    vec2 half_ = vec2(0.5 * gfx_aspect(), 0.5);
    vec2 e2 = half_ - abs(p);
    float e = min(e2.x, e2.y);
    // Coordinate running around the frame so flames flow along it.
    float around = atan(p.y, p.x / gfx_aspect()) * 3.0;

    vec2 q = vec2(around * 2.0 + 0.3 * sin(t * 0.3), e / P_REACH * 2.0 - t * 1.4);
    q += 0.7 * vec2(fbm(q + t * 0.2), fbm(q + 5.0 - t * 0.15));
    float n = fbm(q);
    float heat = clamp(n * 1.25 - e / P_REACH * 1.4 + 0.1, 0.0, 1.0);

    vec3 col = vec3(0.0, 0.02, 0.01);
    col = mix(col, GFX_PRIMARY, smoothstep(0.0, 0.3, heat));
    col = mix(col, GFX_SECONDARY, smoothstep(0.25, 0.7, heat));
    col = mix(col, GFX_ACCENT, smoothstep(0.75, 1.0, heat));
    // Faint wisps drifting toward the centre.
    float wisp = fbm(p * 3.0 + vec2(t * 0.1, -t * 0.2)) * smoothstep(0.4, 0.0, e);
    col += GFX_SECONDARY * pow(wisp, 3.0) * 0.4;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
