// @id nuclear-reactor
// @name Nuclear Reactor
// @category experimental
// @description Looking down into a reactor pool: rows of fuel assemblies glow with eerie Cherenkov blue through the shimmering water.
// @tags reactor, nuclear, cherenkov, blue, glow, science
// @mode background
// @uses gradient value
// @color PRIMARY #2F8BFF
// @color SECONDARY #01040C
// @color ACCENT #B8E2FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    // Water refraction wobble over the whole pool.
    vec2 w = 0.01 * vec2(gnoise(p * 6.0 + t * 0.4), gnoise(p * 6.0 - t * 0.35 + 3.0));
    vec2 q = (p + w) * 7.0;
    vec2 id = floor(q);
    vec2 f = fract(q) - 0.5;
    float inCore = smoothstep(0.62, 0.55, length(id / 7.0 * vec2(0.75, 1.1)));
    // Square assemblies with a grid of rods.
    float assembly = step(max(abs(f.x), abs(f.y)), 0.42) * inCore;
    vec2 rf = fract(f * 6.0) - 0.5;
    float rods = smoothstep(0.32, 0.22, length(rf)) * assembly;
    float power = 0.6 + 0.4 * vnoise(id * 0.7 + t * 0.15);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * 0.45 * exp(-length(p) * 2.0) * power;
    col += mix(GFX_PRIMARY, GFX_ACCENT, rods * power) * (assembly * 0.06 + rods * 0.45) * power;
    col += GFX_ACCENT * pow(vnoise(q * 3.0 + t), 6.0) * 0.15 * inCore;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
