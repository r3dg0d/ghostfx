// @id eclipse
// @name Eclipse
// @category space
// @description A total solar eclipse: the black disc of the moon ringed by a pearly corona and streamers, with a diamond ring flaring as totality ends.
// @tags eclipse, sun, moon, corona, sky
// @mode background
// @uses fbm hash
// @color PRIMARY #F2F0FF
// @color SECONDARY #03040A
// @color ACCENT #FFD27A
// @param CYCLE float 40.0 10.0 120.0 Seconds per eclipse

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    vec2 sun = vec2(0.4, 0.12);
    vec2 moon = sun + vec2((k - 0.5) * 0.06, 0.0);
    float R = 0.085;
    vec2 d = p - sun;
    float r = length(d);
    float cover = smoothstep(0.03, 0.0, abs(k - 0.5));
    vec3 col = GFX_SECONDARY * (1.0 + (1.0 - cover) * 4.0);
    // Corona: radial streamers from direction-space noise.
    vec2 dir = d / max(r, 1e-4);
    float streak = fbm(dir * 3.0 + 2.0) * fbm(dir * 9.0 + t * 0.01);
    float corona = exp(-(r - R) * (12.0 - 6.0 * streak)) * step(R * 0.98, r);
    col += GFX_PRIMARY * corona * (0.35 + 0.65 * streak) * (0.4 + 0.6 * cover);
    // The moon disc.
    float m = smoothstep(R * 1.01, R * 0.99, length(p - moon));
    col = mix(col, vec3(0.0), m);
    // Diamond ring: bright bead on the limb just as totality ends.
    vec2 bead = sun + vec2(R, 0.0) * gfx_rot(0.4);
    float ring = exp(-length(p - bead) * 60.0) * smoothstep(0.52, 0.55, k) * smoothstep(0.62, 0.55, k);
    col += GFX_ACCENT * gfx_flash(ring) * 2.0;
    vec2 sg = p * 80.0;
    col += vec3(0.6) * step(0.993, hash12(floor(sg))) * cover * smoothstep(0.3, 0.0, length(fract(sg) - 0.5));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
