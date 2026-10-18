// @id accretion-disk
// @name Accretion Disk
// @category space
// @description A tilted disk of white-hot gas whirls around a black hole, one side Doppler-brightened, its far side lensed into an arc overhead.
// @tags space, black-hole, accretion, orange, dramatic
// @mode background
// @uses fbm
// @color PRIMARY #FF8A2B
// @color SECONDARY #020104
// @color ACCENT #FFF2D0
// @param TILT float 0.22 0.08 0.6 Disk tilt (vertical squash)

float disk(vec2 q, float t, float inner, float outer) {
    float r = length(q);
    if (r < inner || r > outer) return 0.0;
    // Swirl in Cartesian space (no seam); faster rotation near the centre.
    vec2 s = gfx_rot(t * 0.9 / (r + 0.2)) * q;
    float n = fbm(s * 9.0) * 0.7 + fbm(vec2(r * 30.0, 0.0)) * 0.5;
    float fall = smoothstep(inner, inner * 1.15, r) * smoothstep(outer, outer * 0.6, r);
    return n * fall;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.25, 0.0);
    float rs = 0.1;
    vec3 col = GFX_SECONDARY;

    // Disk seen at an angle.
    vec2 dq = vec2(c.x, c.y / P_TILT);
    float d = disk(dq, t, rs * 1.6, 0.75);
    float doppler = 0.6 + 0.6 * smoothstep(0.4, -0.4, c.x);   // approaching side brighter
    vec3 dc = mix(GFX_PRIMARY, GFX_ACCENT, d * d) * d * doppler * 1.6;
    // Lensed image of the far side: an arc over the shadow.
    float rr = length(c);
    float arc = exp(-pow((rr - rs * 1.75) / 0.02, 2.0)) * smoothstep(-0.02, 0.06, c.y);
    vec3 ac = mix(GFX_PRIMARY, GFX_ACCENT, 0.5) * arc * (0.6 + 0.4 * fbm(vec2(atan(c.y, abs(c.x)) * 6.0, t)));

    float behind = step(0.0, c.y) * step(rr, rs * 1.0);
    float shadow = smoothstep(rs * 0.97, rs * 1.03, rr);
    col += ac;
    col *= shadow;
    // The near half of the disk passes in front of the shadow.
    col += dc * (c.y < 0.0 ? 1.0 : shadow);
    col += GFX_PRIMARY * 0.1 * exp(-rr * 5.0) * (1.0 - behind);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
