// @id clouds
// @name Clouds
// @category nature
// @description Puffy sunlit cumulus drift across a blue sky, self-shadowed so they look solid and three-dimensional.
// @tags clouds, sky, day, blue, calm, bright
// @mode background
// @uses fbm
// @color PRIMARY #FFFFFF
// @color SECONDARY #2E6BB8
// @color ACCENT #8FB4E0
// @param COVER float 0.5 0.2 0.8 Cloud cover

float cloud_density(vec2 p, float t) {
    vec2 q = p * vec2(1.5, 2.5) + vec2(t * 0.03, 0.0);
    float d = fbm(q + 0.4 * fbm(q * 1.7 - t * 0.01));
    return smoothstep(1.0 - P_COVER, 1.0 - P_COVER + 0.3, d);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 sky = mix(GFX_ACCENT, GFX_SECONDARY, smoothstep(-0.5, 0.5, p.y));
    float d = cloud_density(p, t);
    // Self-shadowing: compare with density a step toward the sun.
    vec2 sunDir = normalize(vec2(-0.6, 0.8)) * 0.04;
    float d2 = cloud_density(p + sunDir, t);
    float lit = clamp(0.6 + (d - d2) * 2.5, 0.0, 1.0);
    vec3 cc = mix(GFX_ACCENT * 0.75, GFX_PRIMARY, lit);
    vec3 col = mix(sky, cc, d);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
