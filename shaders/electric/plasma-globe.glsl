// @id plasma-globe
// @name Plasma Globe
// @category electric
// @description A plasma ball: violet filaments writhe from a glowing core to the inside of the glass sphere, flickering and branching.
// @tags plasma, globe, tesla, purple, filaments, electric
// @mode background
// @uses gradient hash
// @flashing true
// @color PRIMARY #C26BFF
// @color SECONDARY #040208
// @color ACCENT #FFC2F5
// @param FILAMENTS int 8 3 14 Number of filaments

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.45, 0.0);
    float R = 0.3;
    float r = length(c);
    vec3 col = GFX_SECONDARY;
    if (r < R) {
        for (int i = 0; i < P_FILAMENTS; i++) {
            float fi = float(i);
            // Filament endpoint wanders around the sphere.
            float a0 = fi * 2.399 + 0.6 * sin(t * (0.3 + 0.1 * hash11(fi)) + fi);
            vec2 dir = vec2(cos(a0), sin(a0));
            float s = clamp(dot(c, dir) / R, 0.0, 1.0);
            vec2 n = vec2(-dir.y, dir.x);
            float flick = floor(t * (GFX_REDUCED_FLASH > 0.5 ? 3.0 : 15.0));
            float off = (gnoise(vec2(s * 5.0, fi * 3.0 + flick * 0.2)) * 0.06 + gnoise(vec2(s * 18.0, flick + fi)) * 0.015) * s;
            float d = abs(dot(c, n) - off);
            float along = step(0.0, dot(c, dir));
            col += mix(GFX_PRIMARY, GFX_ACCENT, 1.0 - s) * (smoothstep(0.004, 0.0, d) + exp(-d * 120.0) * 0.25) * along * (0.6 + 0.4 * s);
            // Contact glow on the glass.
            col += GFX_ACCENT * exp(-length(c - dir * R * 0.98) * 40.0) * 0.4;
        }
        col += GFX_ACCENT * exp(-r * 25.0) * 1.2 + GFX_PRIMARY * 0.08;
    }
    col += vec3(0.6) * smoothstep(0.005, 0.0, abs(r - R)) * 0.25;
    col += vec3(1.0) * smoothstep(0.03, 0.0, length(c - vec2(-0.12, 0.14))) * 0.1;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
