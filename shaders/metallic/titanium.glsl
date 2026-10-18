// @id titanium
// @name Titanium
// @category metallic
// @description Dark machined titanium with a fine bead-blasted grain, broad soft reflections and a hint of anodised colour.
// @tags titanium, metal, dark, premium, subtle
// @mode background
// @uses value hash color
// @color PRIMARY #5A6170
// @color SECONDARY #121418
// @color ACCENT #6E5BC8

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float grain = hash12(floor(fragCoord / max(gfx_dpi(), 1.0))) * 0.05;
    vec2 l = vec2(sin(t * 0.08) * 0.7, cos(t * 0.06) * 0.3);
    float refl = exp(-dot(p - l, p - l) * 2.5);
    float refl2 = exp(-pow((p.x + p.y * 0.5 + 0.4 * sin(t * 0.05)) * 3.0, 2.0)) * 0.5;
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * (refl * 0.5 + refl2 * 0.3) + grain;
    // Anodised tint where the reflection fades out.
    float film = smoothstep(0.2, 0.6, refl) * smoothstep(0.95, 0.6, refl);
    col += mix(GFX_ACCENT, iridescence(refl * 1.5 + 0.2), 0.4) * film * 0.12;
    col += (vnoise(p * 4.0) - 0.5) * 0.02;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
