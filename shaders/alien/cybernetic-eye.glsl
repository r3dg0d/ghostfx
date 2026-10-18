// @id cybernetic-eye
// @name Cybernetic Eye
// @category alien
// @description A mechanical eye watches the screen: segmented iris rings turn and refocus while the pupil darts around scanning.
// @tags eye, cyborg, mechanical, red, hud, creepy
// @mode background
// @uses hash sdf
// @color PRIMARY #FF3D3D
// @color SECONDARY #050304
// @color ACCENT #FFC0A0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.45, 0.0);
    // Pupil target jumps every ~2s, eased.
    float slot = floor(t / 2.0);
    float e = smoothstep(0.0, 0.25, fract(t / 2.0));
    vec2 look = mix(hash22(vec2(slot - 1.0, 3.0)) - 0.5, hash22(vec2(slot, 3.0)) - 0.5, e) * 0.06;
    vec2 q = c - look;
    float r = length(q);
    float a = atan(q.y, q.x);
    float focus = 0.5 + 0.5 * sin(t * 0.7);
    vec3 col = GFX_SECONDARY;
    // Iris: three segmented rings with independent rotation.
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float R = 0.06 + fi * 0.04 + 0.01 * focus;
        float segs = 8.0 + fi * 6.0;
        float rot = t * (0.3 - fi * 0.2) * (mod(fi, 2.0) < 1.0 ? 1.0 : -1.0);
        float seg = step(0.15, fract((a + rot) / 6.2831 * segs));
        float band = smoothstep(0.012, 0.008, abs(r - R));
        col += GFX_PRIMARY * band * seg * (0.6 - fi * 0.12);
    }
    // Pupil + lens glint.
    float pupil = smoothstep(0.03 + 0.01 * focus, 0.025 + 0.01 * focus, r);
    col = mix(col, vec3(0.0), pupil);
    col += GFX_PRIMARY * exp(-r * 30.0) * 0.4;
    col += GFX_ACCENT * smoothstep(0.008, 0.0, length(q - vec2(-0.012, 0.012)));
    // Housing ring.
    col += GFX_PRIMARY * 0.25 * smoothstep(0.004, 0.0, abs(length(c) - 0.22)) + vec3(0.12) * smoothstep(0.02, 0.0, abs(length(c) - 0.24));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
