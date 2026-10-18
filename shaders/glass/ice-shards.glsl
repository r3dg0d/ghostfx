// @id ice-shards
// @name Ice Shards
// @category glass
// @description Sharp splinters of ice radiate from the corners, each facet refracting cold light with a bright cutting edge.
// @tags ice, shards, crystal, cold, blue, glass
// @mode background
// @uses voronoi hash
// @distorts true
// @color PRIMARY #CFF2FF
// @color SECONDARY #06111C
// @color ACCENT #4FA8FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Stretch the cells radially so they read as long splinters.
    vec2 c = p - vec2(0.55 * gfx_aspect(), 0.5);
    vec2 dir = normalize(c);
    vec2 q = vec2(dot(p, dir) * 2.0, dot(p, vec2(-dir.y, dir.x)) * 11.0);
    vec3 v = voronoi(q, 0.0);
    float edge = smoothstep(0.08, 0.0, v.y - v.x);
    float shard = v.z;
    float lit = 0.5 + 0.5 * sin(t * 0.4 + shard * 12.0);
    vec3 col = GFX_SECONDARY + GFX_ACCENT * (0.08 + 0.12 * shard * lit);
    col += GFX_PRIMARY * edge * (0.25 + 0.45 * lit);
    col *= 0.6 + 0.5 * smoothstep(1.4, 0.2, length(c));
    vec2 off = (hash22(vec2(shard * 91.0, 1.0)) - 0.5) * 1.5 * gfx_dpi() / iResolution.xy;
    fragColor = gfx_compose(uv, gfx_term(uv + gfx_text_offset(off)), col);
}
