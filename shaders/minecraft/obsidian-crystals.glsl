// @id obsidian-crystals
// @name Obsidian Crystals
// @category minecraft
// @description Glassy black-violet crystal facets catch a slowly circling light, with sparks of purple glinting across them.
// @tags obsidian, crystal, dark, purple, facets, minecraft-inspired
// @mode background
// @uses voronoi hash
// @inspired Minecraft obsidian (original procedural interpretation, no game assets)
// @color PRIMARY #3A1670
// @color SECONDARY #050309
// @color ACCENT #D6A8FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec3 v = voronoi(p * 5.0, 0.0);
    // Each facet gets a random tilted normal; lighting is flat per facet.
    vec2 tilt = (hash22(vec2(v.z * 91.0, 3.0)) - 0.5) * 1.6;
    vec3 n = normalize(vec3(tilt, 1.0));
    vec3 l = normalize(vec3(cos(t * 0.3) * 0.8, sin(t * 0.23) * 0.8, 0.7));
    float diff = max(dot(n, l), 0.0);
    float spec = pow(max(dot(reflect(-l, n), vec3(0.0, 0.0, 1.0)), 0.0), 30.0);
    float edge = 1.0 - smoothstep(0.0, 0.05, v.y - v.x);

    vec3 col = GFX_SECONDARY + GFX_PRIMARY * diff * 0.5;
    col += GFX_ACCENT * spec * 0.7;
    col += GFX_PRIMARY * edge * 0.35;
    // Glints travelling across.
    vec2 g = p * 30.0;
    vec2 id = floor(g);
    float gl = step(0.97, hash12(id)) * pow(max(sin(t * 2.0 + hash12(id + 2.0) * 30.0), 0.0), 20.0);
    col += GFX_ACCENT * gl * smoothstep(0.3, 0.0, length(fract(g) - 0.5));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
