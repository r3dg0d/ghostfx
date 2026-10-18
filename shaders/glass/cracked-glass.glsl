// @id cracked-glass
// @name Cracked Glass
// @category glass
// @description A pane struck in one spot: radial and ring fractures catch the light, and each shard sits slightly askew.
// @tags glass, cracked, broken, shards, dramatic
// @mode background
// @uses hash value
// @distorts true
// @color PRIMARY #E8F1FF
// @color SECONDARY #0B0D12
// @color ACCENT #7E9BC9
// @param IMPACT_X float 0.45 -0.85 0.85 Impact point x
// @param IMPACT_Y float 0.1 -0.45 0.45 Impact point y
// @param SPOKES float 14.0 5.0 30.0 Radial crack count

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(P_IMPACT_X, P_IMPACT_Y);
    float r = length(c);
    float a = atan(c.y, c.x);
    float n = floor(P_SPOKES);
    // Radial cracks: jittered sector boundaries that wander with radius.
    float s = (a / 6.2831 + 0.5) * n;
    float wander = (vnoise(vec2(floor(s) * 3.1, r * 6.0)) - 0.5) * 0.5;
    float sid = floor(s + wander);
    float fs = abs(fract(s + wander) - 0.5);
    float radial = smoothstep(0.03 / (r * 6.0 + 0.3), 0.0, 0.5 - fs);
    // Concentric fractures at hashed radii.
    float rr = r * 7.0;
    float ring = smoothstep(0.025, 0.0, 0.5 - abs(fract(rr + 0.2 * vnoise(vec2(a * 3.0, sid))) - 0.5)) * step(hash12(vec2(sid, floor(rr))), 0.55) * smoothstep(1.2, 0.2, r);
    float crack = max(radial * smoothstep(1.4, 0.0, r), ring);
    crack = max(crack, smoothstep(0.03, 0.0, r - 0.01));
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.04;
    // Each shard reflects a slightly different brightness.
    float shard = hash12(vec2(sid, floor(rr)));
    col += GFX_ACCENT * shard * 0.03 * smoothstep(1.0, 0.0, r);
    float glint = 0.6 + 0.4 * sin(t * 0.8 + shard * 20.0);
    col += GFX_PRIMARY * crack * glint * 0.8;
    vec2 off = (hash22(vec2(sid, floor(rr))) - 0.5) * 2.0 * gfx_dpi() / iResolution.xy * smoothstep(1.0, 0.0, r);
    fragColor = gfx_compose(uv, gfx_term(uv + gfx_text_offset(off)), col);
}
