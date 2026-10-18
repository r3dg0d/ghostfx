// @id nether-atmosphere
// @name Nether Atmosphere
// @category minecraft
// @description Thick crimson fog rolls beneath a blocky rock ceiling while embers drift up from a lava sea glowing below.
// @tags nether, red, fog, embers, pixel, minecraft-inspired
// @mode background
// @uses fbm hash
// @inspired Minecraft's Nether (original procedural interpretation, no game assets)
// @color PRIMARY #8E1B12
// @color SECONDARY #1E0605
// @color ACCENT #FF8A2A

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float PX = 100.0;
    vec2 q = (floor(p * PX) + 0.5) / PX;

    vec3 col = mix(GFX_SECONDARY, GFX_PRIMARY * 0.6, 0.5 + 0.5 * q.y);
    // Two parallax fog layers.
    float f1 = fbm(vec2(q.x * 2.0 + t * 0.05, q.y * 3.0));
    float f2 = fbm(vec2(q.x * 3.5 - t * 0.08, q.y * 4.0 + 7.0));
    col = mix(col, GFX_PRIMARY, f1 * 0.45);
    col = mix(col, GFX_PRIMARY * 1.3, pow(f2, 2.0) * 0.35);

    // Netherrack ceiling.
    float ceil_ = 0.38 + 0.06 * fbm(vec2(floor(q.x * 25.0), 1.0));
    if (q.y > ceil_) col = GFX_PRIMARY * (0.35 + 0.25 * hash12(floor(q * PX * 0.5)));
    // Lava sea glow from below.
    col += GFX_ACCENT * 0.35 * smoothstep(-0.2, -0.55, q.y);
    if (q.y < -0.45 + 0.01 * sin(q.x * 30.0 + t)) col = mix(GFX_ACCENT, vec3(1.0, 0.9, 0.4), step(0.85, hash12(floor(q * PX + vec2(t * 4.0, 0.0)))));

    // Embers.
    vec2 g = p * 35.0 + vec2(sin(t * 0.5 + p.y * 5.0), -t * 2.0);
    vec2 id = floor(g);
    if (hash12(id) < 0.05) {
        vec2 f = fract(g) - 0.5;
        col += GFX_ACCENT * step(max(abs(f.x), abs(f.y)), 0.1) * 1.2;
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
