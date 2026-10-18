// @id time-vortex
// @name Time Vortex
// @category portals
// @description A spiralling temporal tunnel lined with clock-face rings, each ticking at its own pace as they recede.
// @tags vortex, time, tunnel, clock, spiral, blue
// @mode background
// @uses fbm value
// @color PRIMARY #3D7BFF
// @color SECONDARY #02030A
// @color ACCENT #FFB23D

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.3, 0.0);
    float r = length(c);
    float z = 0.25 / max(r, 0.01) + t * 0.5;
    // Swirling cloud walls (direction vector + depth: no seam).
    vec2 dir = gfx_rot(z * 0.8) * (c / max(r, 1e-4));
    float cloud = fbm3(vec3(dir * 1.3, z * 0.4));
    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY, cloud) * smoothstep(0.02, 0.3, r);
    // Clock rings at regular depths with 12 ticks each, rotating at varied rates.
    float ring = fract(z * 0.5);
    float ringId = floor(z * 0.5);
    float band = smoothstep(0.08, 0.0, abs(ring - 0.5)) ;
    float ang = atan(c.y, c.x) + t * (0.2 + 0.4 * fract(ringId * 0.618)) * (mod(ringId, 2.0) < 1.0 ? 1.0 : -1.0);
    float ticks = smoothstep(0.85, 0.95, abs(cos(ang * 6.0)));
    col += GFX_ACCENT * band * (0.15 + ticks * 0.9) * smoothstep(0.03, 0.2, r);
    col += mix(GFX_ACCENT, vec3(1.0), 0.5) * exp(-r * 18.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
