// @id ender-portal
// @name Ender Portal
// @category minecraft
// @description Parallax layers of drifting teal and violet specks over a black void, an original take on the End portal surface.
// @tags portal, purple, space, starfield, minecraft-inspired
// @mode background
// @uses hash particles
// @inspired Minecraft's End portal block (original procedural interpretation, no game assets)
// @color PRIMARY #8B5CF6
// @color SECONDARY #1B6F6A
// @color ACCENT #C8F7EE
// @param DEPTH float 1.0 0.3 2.0 Parallax depth between layers
// @param DENSITY float 1.0 0.3 2.0 Speck density
// @preset cinematic DEPTH=1.5 DENSITY=1.4

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec3 col = vec3(0.01, 0.012, 0.02);
    // Each layer is a rotated, scaled grid of square specks scrolling at its
    // own speed; nearer layers are larger, brighter and faster.
    for (int i = 0; i < 2 * GFX_LAYERS; i++) {
        float fi = float(i);
        float depth = 1.0 + fi * 0.55 * P_DEPTH;
        vec2 q = gfx_rot(fi * 1.7 + 0.3) * p * (6.0 + fi * 3.0) * P_DENSITY;
        q += vec2(t * (0.08 + 0.05 / depth), t * 0.03 * fi);
        vec2 id = floor(q);
        vec2 f = fract(q) - 0.5;
        float h = hash12(id + fi * 13.1);
        float on = step(0.86, h);
        float sq = max(abs(f.x), abs(f.y));
        float speck = on * smoothstep(0.22, 0.12, sq);
        float hue = hash12(id + 91.7 + fi);
        vec3 tint = mix(GFX_SECONDARY, GFX_PRIMARY, step(0.55, hue));
        tint = mix(tint, GFX_ACCENT, step(0.93, hue));
        float pulse = 0.6 + 0.4 * sin(t * 1.3 + h * 40.0);
        col += tint * speck * pulse * (1.4 / depth);
    }
    // Faint dark-teal haze so the void is never perfectly flat.
    col += GFX_SECONDARY * 0.06 * (1.0 - length(p));

    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
