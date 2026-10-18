// @id nanobot-swarm
// @name Nanobot Swarm
// @category particles
// @description A swarm of metallic nanobots streams along an invisible flow, bunching into a vortex and dispersing again.
// @tags swarm, nanobots, particles, flow, silver
// @mode background
// @uses hash gradient
// @color PRIMARY #D9E4F2
// @color SECONDARY #05070A
// @color ACCENT #3DB8FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Back-advect the sample point through a curl-noise flow, then look up
    // a sparse static dot field: dots appear to stream along the flow.
    vec2 q = p;
    for (int i = 0; i < 4; i++) {
        float e = 0.02;
        float n = gnoise(q * 2.0 + t * 0.1);
        vec2 g = vec2(gnoise((q + vec2(e, 0.0)) * 2.0 + t * 0.1) - n, gnoise((q + vec2(0.0, e)) * 2.0 + t * 0.1) - n) / e;
        vec2 swirl = vec2(-q.y, q.x) * (0.6 + 0.4 * sin(t * 0.2));
        q -= (vec2(g.y, -g.x) * 0.02 + swirl * 0.02) ;
    }
    vec2 gq = q * 70.0 + vec2(t * 1.5, 0.0);
    vec2 id = floor(gq);
    float h = hash12(id);
    float dot_ = step(0.82, h) * smoothstep(0.3, 0.1, length(fract(gq) - 0.5));
    col += mix(GFX_PRIMARY, GFX_ACCENT, step(0.97, h)) * dot_ * 0.8;
    col += GFX_ACCENT * 0.05 * exp(-length(p) * 3.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
