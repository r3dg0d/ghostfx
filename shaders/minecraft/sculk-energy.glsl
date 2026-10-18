// @id sculk-energy
// @name Sculk Energy
// @category minecraft
// @description Deep-dark organic veins throb with cyan light as vibration rings ripple out from hidden sensors.
// @tags sculk, cyan, organic, pulse, dark, minecraft-inspired
// @mode background
// @uses voronoi hash
// @inspired Minecraft's sculk blocks (original procedural interpretation, no game assets)
// @color PRIMARY #22E3D8
// @color SECONDARY #031317
// @color ACCENT #0B4F6C

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float PX = 140.0;
    vec2 q = (floor(p * PX) + 0.5) / PX;

    vec3 v = voronoi(q * 7.0, 0.0);
    float vein = 1.0 - smoothstep(0.0, 0.12, v.y - v.x);
    vec3 col = GFX_SECONDARY + GFX_ACCENT * 0.25 * hash12(floor(q * PX * 0.5));

    // Vibration rings from sensors that trigger in turn.
    float ring = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float cyc = floor(t / 4.0 + fi / 3.0);
        float age = fract(t / 4.0 + fi / 3.0) * 4.0;
        vec2 c = (hash22(vec2(fi, cyc)) - 0.5) * vec2(gfx_aspect(), 1.0) * 0.8;
        float r = length(q - c);
        ring += exp(-pow((r - age * 0.35) * 18.0, 2.0)) * exp(-age * 0.6);
        col += GFX_PRIMARY * smoothstep(0.03, 0.0, max(abs(q.x - c.x), abs(q.y - c.y)) - 0.012) * (0.4 + 0.6 * exp(-age));
    }
    float breathe = 0.35 + 0.25 * sin(t * 1.2 + v.z * 6.28);
    col += GFX_PRIMARY * vein * (breathe + ring * 1.4);
    col += GFX_PRIMARY * ring * 0.15;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
