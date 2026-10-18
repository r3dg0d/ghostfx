// @id reality-break
// @name Reality Break
// @category glitch
// @description The screen shatters into drifting Voronoi shards with glowing seams, each tilted and colour-split as space comes apart.
// @tags glitch, shatter, distortion, extreme, surreal
// @mode post
// @uses voronoi hash crt sdf
// @distorts true
// @color PRIMARY #FF4BD8
// @color ACCENT #6BF4FF
// @param SHATTER float 0.25 0.0 1.0 How far shards drift apart
// @param SHARDS float 6.0 2.0 14.0 Shard density
// @preset subtle SHATTER=0.08
// @preset cinematic SHATTER=0.6

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 v = voronoi(p * P_SHARDS, 0.0);
    float edge = voronoi_edge(p * P_SHARDS, 0.0);
    float pulse = 0.5 + 0.5 * sin(t * 0.7 + v.z * 6.28);
    float D = P_SHATTER * GFX_DISTORT_TEXT * pulse;
    vec2 dir = (hash22(vec2(v.z * 37.0, 1.0)) - 0.5);
    vec2 off = dir * 0.05 * D;
    // Slight per-shard rotation about the screen centre.
    vec2 suv = (gfx_rot((v.z - 0.5) * 0.06 * D) * (uv - 0.5)) + 0.5 + off;
    vec3 col = term_chroma(suv, vec2(0.004 * D, 0.0));
    vec4 term = gfx_term(suv);
    float seam = smoothstep(0.03, 0.0, edge);
    col = mix(col, mix(GFX_PRIMARY, GFX_ACCENT, v.z), seam * (0.4 + 0.6 * P_SHATTER));
    col += mix(GFX_PRIMARY, GFX_ACCENT, v.z) * glow(edge, 0.01) * 0.25 * P_SHATTER;
    fragColor = gfx_post(term, col);
}
