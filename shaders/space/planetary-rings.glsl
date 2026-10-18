// @id planetary-rings
// @name Planetary Rings
// @category space
// @description Sweeping close-up of a ringed giant: hundreds of fine ringlets, gaps, and the planet's shadow falling across them.
// @tags space, saturn, rings, planet, elegant
// @mode background
// @uses value hash
// @color PRIMARY #E8CFA0
// @color SECONDARY #03030A
// @color ACCENT #A07850

float ringlets(float r) {
    if (r < 0.55 || r > 1.25) return 0.0;
    float n = vnoise(vec2(r * 120.0, 0.0)) * 0.6 + vnoise(vec2(r * 37.0, 3.0)) * 0.4;
    float gap = smoothstep(0.004, 0.012, abs(r - 0.97)) * smoothstep(0.002, 0.006, abs(r - 1.12));
    return n * gap * smoothstep(0.55, 0.62, r) * smoothstep(1.25, 1.18, r);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = gfx_rot(-0.18) * (p - vec2(-0.75, -0.55));
    vec3 col = GFX_SECONDARY;
    vec2 sg = p * 80.0;
    col += vec3(0.7) * step(0.99, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5));

    float R = 0.5;
    vec2 rq = vec2(c.x, c.y / 0.28);
    float rr = length(rq);
    float ring = ringlets(rr / R * 0.5 + 0.0);
    vec3 rc = mix(GFX_ACCENT, GFX_PRIMARY, ring) * ring;
    // Slow sparkle drifting along the ring plane.
    rc *= 0.85 + 0.15 * vnoise(vec2(atan(rq.y, abs(rq.x)) * 40.0 + t * 0.2, rr * 50.0));
    float planet = smoothstep(R + 0.003, R, length(c));
    // Planet shadow on the rings (behind the planet, offset away from the sun).
    float shadow = smoothstep(0.02, 0.0, abs(c.x * 0.3 + c.y) - 0.0) * step(0.0, c.x) * smoothstep(R * 1.6, R, length(c));
    vec3 pc = mix(GFX_ACCENT, GFX_PRIMARY, 0.5 + 0.5 * sin(c.y * 40.0 + vnoise(c * 10.0) * 2.0));
    pc *= smoothstep(-0.6, 0.4, dot(normalize(c + 1e-4), normalize(vec2(1.0, 0.6))) * length(c) / R);
    // Ring passes in front of the planet on the near side (rq.y < 0).
    col = mix(col, pc, planet);
    float front = step(rq.y, 0.0);
    col = mix(col, col + rc * (1.0 - shadow * 0.85), front + (1.0 - front) * (1.0 - planet));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
