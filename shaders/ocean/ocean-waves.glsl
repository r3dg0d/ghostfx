// @id ocean-waves
// @name Ocean Waves
// @category ocean
// @description Rolling open-ocean swells seen from just above the water, with sky reflections and a low sun glinting on the crests.
// @tags ocean, water, waves, sun, horizon, calm
// @mode background
// @uses gradient lighting
// @color PRIMARY #0B3954
// @color SECONDARY #6A9EC0
// @color ACCENT #FFE2B0
// @param HORIZON float 0.14 -0.2 0.4 Horizon height (screen units above centre)
// @param CHOP float 1.0 0.3 2.0 Wave choppiness
// @preset cinematic CHOP=1.3

// Choppy wave field: octaves of directional crests (1 - |sin|) with a
// noise-perturbed phase so the pattern never repeats visibly.
float sea(vec2 x, float t) {
    float h = 0.0, amp = 0.55, freq = 0.22;
    vec2 dir = vec2(0.96, 0.28);
    for (int i = 0; i < GFX_OCTAVES; i++) {
        vec2 q = x * freq;
        float ph = dot(dir, q) * 6.0 + t * (1.0 + 0.4 * float(i)) + gnoise(q * 1.7 + 0.2 * t) * 1.8;
        h += amp * pow(1.0 - abs(sin(ph)), 0.6 + 0.6 * P_CHOP);
        dir = gfx_rot(1.1) * dir;
        freq *= 1.9;
        amp *= 0.45;
    }
    return h;
}

vec3 sky_col(float y) {
    vec3 zen = GFX_SECONDARY * 0.4;
    vec3 hor = mix(GFX_SECONDARY, GFX_ACCENT, 0.3) * 0.85;
    return mix(hor, zen, smoothstep(0.0, 0.6, y));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = P_HORIZON;
    vec3 sun = normalize(vec3(0.35, 0.12, 1.0));
    vec3 col;

    if (p.y > hy) {
        float y = p.y - hy;
        col = sky_col(y * 2.0);
        vec2 sd = p - vec2(0.35 * gfx_aspect() * 0.5, hy + 0.12);
        col += GFX_ACCENT * (0.6 * exp(-dot(sd, sd) * 900.0) + 0.25 * exp(-length(sd) * 9.0));
    } else {
        float dy = hy - p.y + 0.002;
        float z = 0.35 / dy;
        vec2 w = vec2(p.x * z, z + t * 0.6);
        float e = 0.02 + 0.015 * z;
        float h = sea(w, t);
        float hx = sea(w + vec2(e, 0.0), t);
        float hz = sea(w + vec2(0.0, e), t);
        vec3 n = normalize(vec3(h - hx, e * 5.0, h - hz));
        vec3 v = normalize(vec3(p.x, -dy, 1.0));
        vec3 r = reflect(v, n);
        float fr = fresnel_schlick(max(dot(-v, n), 0.0), 0.04);
        vec3 water = mix(GFX_PRIMARY * 0.5, GFX_PRIMARY * 1.3 + vec3(0.0, 0.06, 0.05), h * 0.8);
        col = mix(water, sky_col(max(r.y, 0.0) * 3.0) * 0.8, clamp(fr * 1.2, 0.0, 0.75));
        col += GFX_ACCENT * pow(max(dot(r, sun), 0.0), 180.0) * 1.6;
        col = mix(col, sky_col(0.0), smoothstep(8.0, 60.0, z));
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
