// @id nanotech-assembly
// @name Nanotech Assembly
// @category experimental
// @description Voxels fly in and lock into place, assembling a glowing lattice structure layer by layer before it dissolves and rebuilds.
// @tags nanotech, voxels, assembly, cyan, sci-fi
// @mode background
// @uses hash
// @color PRIMARY #4DE6FF
// @color SECONDARY #03060A
// @color ACCENT #FFFFFF
// @param CYCLE float 16.0 6.0 60.0 Seconds per build

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float k = fract(t / P_CYCLE);
    vec2 c = p - vec2(0.4, -0.05);
    vec2 g = c * 22.0;
    vec2 id = floor(g);
    vec2 f = fract(g) - 0.5;
    // Target structure: a stepped pyramid.
    float inShape = step(abs(id.x) + max(id.y + 5.0, 0.0) * 0.9, 7.0) * step(-6.0, id.y);
    // Each voxel arrives at a time ordered bottom-up, flying in from the right.
    float order = (id.y + 6.0) / 13.0 + hash12(id) * 0.08;
    float arrive = clamp((k * 1.3 - order * 0.9) * 6.0, 0.0, 1.0);
    float leave = smoothstep(0.85, 1.0, k);
    vec2 from = vec2(8.0, 3.0) * (1.0 - arrive);
    vec2 fo = f - from;
    float box = smoothstep(0.42, 0.36, max(abs(fo.x), abs(fo.y))) * step(0.001, arrive) * (1.0 - leave);
    float lockFlash = exp(-pow((arrive - 1.0) * 30.0, 2.0)) * step(0.999, arrive);
    vec3 col = GFX_SECONDARY;
    col += GFX_PRIMARY * inShape * box * (0.35 + 0.3 * (1.0 - arrive)) ;
    col += GFX_ACCENT * inShape * box * lockFlash * 0.6;
    col += GFX_PRIMARY * inShape * smoothstep(0.5, 0.45, max(abs(f.x), abs(f.y))) * 0.04;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
