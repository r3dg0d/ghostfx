// @id rain-on-glass
// @name Rain on Glass
// @category ocean
// @description Rivulets of rain racing down the pane in stop-start runs, refracting a blurred night city behind the text.
// @tags rain, glass, water, refraction, night, cozy
// @mode glow
// @uses hash value
// @distorts true
// @color PRIMARY #1B2A4A
// @color SECONDARY #FF9F5A
// @color ACCENT #9FD8FF
// @param DROPS float 1.0 0.3 2.0 Number of rivulets
// @param REFRACTION float 1.0 0.0 2.0 Strength of refraction

// One column-per-drop layer in screen units. Returns the lens refraction
// vector in .xy and drop coverage in .z.
vec3 drop_layer(vec2 p, float t, float scale) {
    float cw = 0.11 / scale;
    float cid = floor(p.x / cw);
    float h = hash11(cid * 1.37 + scale * 11.0);
    if (h > 0.35 + 0.4 * P_DROPS) return vec3(0.0);
    float h2 = hash11(cid * 7.13 + scale);
    float x0 = (cid + 0.5) * cw + (h2 - 0.5) * cw * 0.5;
    // Stick-slip descent over the full screen height.
    float ph = t * (0.08 + 0.12 * h) + h2 * 10.0;
    float y = 0.65 - 1.3 * fract(ph + 0.06 * sin(ph * 6.2831));
    float wob = 0.006 * sin(p.y * 35.0 + h * 9.0);
    vec2 d = vec2(p.x - x0 - wob, p.y - y);
    float r = (0.014 + 0.012 * h2) / sqrt(scale);
    float drop = smoothstep(r, r * 0.55, length(d * vec2(1.0, 0.8)));
    float above = d.y;
    float tail = step(0.0, above) * exp(-above * 2.5);
    float trail = smoothstep(r * 0.3, 0.0, abs(d.x)) * tail * 0.5;
    float bi = floor(above * 22.0);
    vec2 bd = vec2(d.x, (fract(above * 22.0) - 0.5) / 22.0);
    float bead = smoothstep(r * 0.45, r * 0.15, length(bd)) * tail * step(0.45, hash11(bi + cid * 3.1));
    float m = max(drop, max(trail, bead));
    vec2 lens = d / r * drop + bd / r * bead + vec2(d.x / r, 0.0) * trail;
    return vec3(lens, m);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();

    vec3 a = drop_layer(p, t, 1.0);
    vec3 b = drop_layer(p * 1.6 + 3.7, t * 1.2, 1.6);
    vec2 off = clamp(a.xy + b.xy * 0.7, -1.5, 1.5) * 0.008 * P_REFRACTION;
    float mask = max(a.z, b.z);

    // Out-of-focus night city: gradient plus big soft bokeh discs.
    vec2 q = p - off * 6.0;
    vec3 fx = mix(GFX_PRIMARY * 0.6, GFX_PRIMARY * 1.3, smoothstep(-0.5, 0.5, q.y));
    for (int i = 0; i < 2; i++) {
        vec2 g = q * (4.0 + float(i) * 3.0) + float(i) * 7.0;
        vec2 id = floor(g);
        float h = hash12(id);
        float d = length(fract(g) - 0.5 - (hash22(id) - 0.5) * 0.4);
        vec3 lc = mix(GFX_SECONDARY, GFX_ACCENT, step(0.6, h));
        fx += lc * smoothstep(0.35, 0.28, d) * step(0.6, h) * 0.2;
    }
    fx *= 1.0 + mask * 0.35;

    vec4 term = gfx_term(uv + gfx_text_offset(off));
    vec3 light = GFX_ACCENT * mask * 0.22 + vec3(1.0) * pow(mask, 6.0) * 0.18;
    fragColor = gfx_compose_glow(uv, term, fx, light);
}
