// @id spiral-galaxy
// @name Spiral Galaxy
// @category space
// @description A tilted spiral galaxy turns slowly: a golden bulge, blue star-forming arms and dark dust lanes.
// @tags space, galaxy, spiral, stars, majestic
// @mode background
// @uses fbm hash
// @color PRIMARY #7FA8FF
// @color SECONDARY #020309
// @color ACCENT #FFD9A0
// @param ARMS float 2.0 1.0 5.0 Number of arms
// @param TILT float 0.55 0.2 1.0 Disc tilt

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = gfx_rot(0.4) * (p - vec2(0.3, 0.0));
    c.y /= P_TILT;
    float r = length(c);
    // Rotate the disc, then measure distance to logarithmic spiral arms.
    vec2 rc = gfx_rot(-t * 0.05) * c;
    float a = atan(rc.y, rc.x);
    float arms = floor(P_ARMS);
    float spiral = cos(arms * (a - log(r + 0.01) * 2.2));
    float armMask = pow(0.5 + 0.5 * spiral, 3.0) * smoothstep(0.65, 0.1, r);
    float dust = fbm(gfx_rot(-t * 0.05) * c * 9.0);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * armMask * (0.4 + 0.8 * dust) * 0.9;
    col *= 1.0 - 0.6 * smoothstep(0.5, 0.75, dust) * armMask;
    col += GFX_ACCENT * exp(-r * 9.0) * 1.2 + GFX_ACCENT * 0.15 * exp(-r * 3.0);
    // Star clusters along the arms and a field of background stars.
    vec2 g = rc * 70.0;
    vec2 id = floor(g);
    col += vec3(0.9, 0.95, 1.0) * step(0.9, hash12(id)) * smoothstep(0.3, 0.0, length(fract(g) - 0.5)) * armMask * 1.5;
    vec2 sg = p * 60.0;
    col += vec3(0.7) * step(0.985, hash12(floor(sg))) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
