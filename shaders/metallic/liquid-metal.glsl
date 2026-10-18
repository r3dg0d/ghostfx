// @id liquid-metal
// @name Liquid Metal
// @category metallic
// @description Pools of mercury bulge, merge and split across the screen, mirroring a bright studio around them.
// @tags metal, mercury, liquid, chrome, silver
// @mode background
// @uses lighting hash
// @color PRIMARY #E6EBF2
// @color SECONDARY #0A0B0E
// @color ACCENT #6C7A96
// @param BLOBS int 7 3 12 Number of mercury blobs

float field(vec2 p, float t) {
    float f = 0.0;
    for (int i = 0; i < P_BLOBS; i++) {
        float fi = float(i);
        vec2 c = vec2(sin(t * (0.13 + 0.05 * hash11(fi)) + fi * 2.1) * 0.75, cos(t * (0.11 + 0.04 * hash11(fi + 3.0)) + fi * 1.3) * 0.38);
        float r = 0.07 + 0.05 * hash11(fi + 7.0);
        f += r * r / max(dot(p - c, p - c), 1e-4);
    }
    return f;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float f = field(p, t);
    float e = 0.002;
    // Bounded height: 0 at the blob rim, rising to 1 at the centre.
    float h = clamp(1.0 - 1.0 / max(f, 1e-3), 0.0, 1.0);
    float hx = clamp(1.0 - 1.0 / max(field(p + vec2(e, 0.0), t), 1e-3), 0.0, 1.0);
    float hy = clamp(1.0 - 1.0 / max(field(p + vec2(0.0, e), t), 1e-3), 0.0, 1.0);
    float inside = smoothstep(0.95, 1.05, f);
    vec3 n = normalize(vec3(-(hx - h) / e * 0.06, -(hy - h) / e * 0.06, 1.0));
    vec3 r = reflect(vec3(0.0, 0.0, -1.0), n);
    vec3 env = studio_env(normalize(vec3(r.x, r.y + 0.3, r.z)), GFX_PRIMARY * 0.8, GFX_ACCENT * 0.35);
    vec3 metal = env * (0.55 + 0.45 * fresnel_schlick(n.z, 0.6));
    vec3 col = mix(GFX_SECONDARY, metal, inside);
    col += GFX_ACCENT * 0.08 * smoothstep(0.5, 0.95, f) * (1.0 - inside);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
