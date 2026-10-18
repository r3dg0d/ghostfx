// @id beacon-beam
// @name Beacon Beam
// @category minecraft
// @description A brilliant cyan beam shoots straight up through the night, banded with rising light and surrounded by floating motes.
// @tags beacon, beam, light, cyan, pixel, minecraft-inspired
// @mode background
// @uses hash value sdf
// @inspired Minecraft's beacon (original procedural interpretation, no game assets)
// @color PRIMARY #6FF7FF
// @color SECONDARY #050913
// @color ACCENT #FFFFFF
// @param X float 0.55 -0.9 0.9 Beam position (screen units from centre)
// @param WIDTH float 0.03 0.01 0.08 Beam core width

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec3 col = mix(GFX_SECONDARY, GFX_SECONDARY * 2.0 + vec3(0.0, 0.02, 0.05), smoothstep(0.5, -0.5, p.y));
    float dx = abs(p.x - P_X);
    float bands = 0.75 + 0.25 * sin(p.y * 40.0 - t * 6.0) * sin(p.y * 13.0 - t * 2.0);
    float core = smoothstep(P_WIDTH, P_WIDTH * 0.3, dx);
    col += GFX_PRIMARY * (glow(dx, P_WIDTH * 0.8) * 0.5 + exp(-dx * 6.0) * 0.2) * bands;
    col = mix(col, mix(GFX_PRIMARY, GFX_ACCENT, 0.6) * bands, core * 0.9);

    // Base block glow.
    vec2 b = p - vec2(P_X, -0.47);
    col += GFX_PRIMARY * 0.6 * smoothstep(0.03, 0.0, max(abs(b.x), abs(b.y)) - 0.02);
    // Pixel motes rising around the beam.
    vec2 g = (p - vec2(P_X, 0.0)) * vec2(30.0, 30.0) + vec2(0.0, -t * 2.0);
    vec2 id = floor(g);
    float m = step(0.92, hash12(id)) * step(max(abs(fract(g.x) - 0.5), abs(fract(g.y) - 0.5)), 0.12);
    col += GFX_PRIMARY * m * exp(-dx * 6.0) * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
