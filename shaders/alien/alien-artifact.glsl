// @id alien-artifact
// @name Alien Artifact
// @category alien
// @description A black monolith floats above a dim plain, its surface lit by slowly scrolling runes and a cold light sweeping its edges.
// @tags monolith, artifact, alien, runes, mysterious
// @mode background
// @uses hash sdf fbm
// @color PRIMARY #6BFFE0
// @color SECONDARY #020405
// @color ACCENT #C2D6FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY, GFX_ACCENT * 0.08, smoothstep(0.5, -0.3, p.y));
    float hover = 0.02 * sin(t * 0.5);
    vec2 m = p - vec2(0.45, 0.02 + hover);
    float d = sd_box(m, vec2(0.07, 0.24));
    float body = smoothstep(0.002, -0.002, d);
    // Runes: glyph cells on the face, revealed by a scrolling band.
    vec2 g = (m + vec2(0.07, 0.24)) * vec2(60.0, 60.0);
    vec2 id = floor(g);
    float rune = step(0.55, hash12(id + floor(id.y / 3.0) * 7.0)) * step(0.25, fract(g.x)) * step(0.25, fract(g.y));
    float band = exp(-pow(fract(m.y * 1.5 - t * 0.1) - 0.5, 2.0) * 40.0);
    vec3 face = vec3(0.02) + GFX_PRIMARY * rune * band * 0.7;
    col = mix(col, face, body);
    // Edge light sweeping up and down.
    float sweep = exp(-pow(m.y - 0.24 * sin(t * 0.4), 2.0) * 200.0);
    col += GFX_ACCENT * smoothstep(0.003, 0.0, abs(d)) * (0.15 + 0.8 * sweep);
    // Shadow/glow on the ground.
    float ground = -0.32 + 0.01 * fbm(vec2(p.x * 5.0, 0.0));
    col = mix(col, vec3(0.015), smoothstep(0.002, 0.0, p.y - ground));
    col += GFX_PRIMARY * 0.12 * exp(-length((p - vec2(0.45, ground)) * vec2(1.0, 6.0)) * 6.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
