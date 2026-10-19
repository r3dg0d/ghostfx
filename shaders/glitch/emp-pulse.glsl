// @id emp-pulse
// @name EMP Pulse
// @category glitch
// @description An electromagnetic pulse shockwave sweeps outward from the centre, leaving a brief wake of colour-split, noisy, shaken pixels.
// @tags emp, shockwave, glitch, pulse, disruption
// @mode post
// @uses hash crt
// @flashing true
// @distorts true
// @color PRIMARY #7AD7FF
// @param PERIOD float 5.0 3.0 30.0 Seconds between pulses

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float age = mod(t, P_PERIOD);
    float R = age / P_PERIOD * 1.15;          // the front spans the whole period, corner to corner
    float r = length(p);
    float front = exp(-pow((r - R) * 25.0, 2.0));
    float wake = smoothstep(R, R - 0.25, r) * exp(-age * 1.2) * step(r, R);
    float D = (front + wake) * GFX_DISTORT_TEXT * GFX_INTENSITY;
    vec2 dir = p / max(r, 1e-3);
    vec2 shake = dir * front * 0.006 + (hash22(floor(fragCoord / 3.0) + floor(t * 30.0)) - 0.5) * 0.003 * wake;
    vec2 suv = uv + shake * D / vec2(gfx_aspect(), 1.0) * 2.0;
    vec4 term = gfx_term(suv);
    vec3 col = term_chroma(suv, dir * 0.004 * D);
    col += GFX_PRIMARY * front * gfx_flash(0.35) * GFX_INTENSITY;
    col += (hash12(fragCoord + floor(t * 40.0)) - 0.5) * 0.15 * wake * GFX_INTENSITY;
    fragColor = gfx_post_k(term, col, 1.0);
}
