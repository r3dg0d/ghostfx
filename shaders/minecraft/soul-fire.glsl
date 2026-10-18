// @id soul-fire
// @name Soul Fire
// @category minecraft
// @description Pixelated pale-blue flames flicker along the bottom while ghostly soul wisps rise slowly through the gloom.
// @tags fire, blue, souls, pixel, eerie, minecraft-inspired
// @mode background
// @uses fbm hash
// @inspired Minecraft's soul fire (original procedural interpretation, no game assets)
// @color PRIMARY #17D4E6
// @color SECONDARY #03080E
// @color ACCENT #E3FFFF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float PX = 80.0;
    vec2 q = (floor(p * PX) + 0.5) / PX;
    float y = q.y + 0.5;

    float n = fbm(vec2(q.x * 5.0, y * 3.0 - t * 2.0));
    float heat = n * 1.3 - y * 2.8 + 0.15;
    heat = floor(clamp(heat, 0.0, 1.0) * 5.0) / 5.0;
    vec3 col = GFX_SECONDARY;
    col = mix(col, vec3(0.02, 0.15, 0.35), step(0.2, heat));
    col = mix(col, GFX_PRIMARY, step(0.4, heat));
    col = mix(col, GFX_ACCENT, step(0.8, heat));
    col += GFX_PRIMARY * 0.1 * exp(-y * 3.0);

    // Soul wisps: soft blobs with two dark "eyes", rising and fading.
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        float life = fract(t * 0.08 + hash11(fi));
        vec2 pos = vec2((hash11(fi * 3.7) - 0.5) * gfx_aspect() * 0.9 + 0.05 * sin(t + fi), -0.3 + life * 0.9);
        vec2 d = q - pos;
        float body = smoothstep(0.035, 0.02, length(d * vec2(1.0, 0.8)));
        float eyes = step(length(vec2(abs(d.x) - 0.009, d.y - 0.004)), 0.005);
        float a = sin(life * 3.1416);
        col = mix(col, GFX_PRIMARY * 0.7 * (1.0 - eyes * 0.8), body * a * 0.7);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
