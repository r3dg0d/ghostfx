// @id stormy-sea
// @name Stormy Sea
// @category ocean
// @description Heavy grey-green swells capped with foam under racing storm clouds, rain streaks and the odd distant flash.
// @tags ocean, storm, waves, rain, dark, dramatic
// @mode background
// @uses fbm hash
// @flashing true
// @color PRIMARY #1F3A3D
// @color SECONDARY #3B4650
// @color ACCENT #DDE7EA
// @param RAIN float 1.0 0.0 2.0 Rain streak density
// @param FLASHES float 1.0 0.0 1.0 Distant lightning brightness
// @preset subtle FLASHES=0.3

float swell(vec2 x, float t) {
    float r = ridged(x * 0.35 + vec2(t * 0.25, t * 0.1));
    return r * 0.8 + 0.4 * sin(x.x * 0.6 + t * 1.3 + x.y * 0.3);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float hy = 0.2;

    // Lightning: rare, random cells of time light up the clouds.
    float slot = floor(t / 3.0);
    float lt = fract(t / 3.0) * 3.0;
    float bolt = step(0.72, hash11(slot)) * exp(-lt * 9.0) * (0.6 + 0.4 * sin(lt * 70.0));
    bolt = gfx_flash(bolt * P_FLASHES);

    vec3 col;
    if (p.y > hy) {
        float c = fbm(vec2(p.x * 2.0 + t * 0.35, p.y * 4.0 - t * 0.05));
        col = mix(GFX_SECONDARY * 0.5, GFX_SECONDARY * 1.3, c);
        col += GFX_ACCENT * bolt * 0.6 * c;
    } else {
        float dy = hy - p.y + 0.003;
        float z = 0.3 / dy;
        vec2 w = vec2(p.x * z, z);
        float e = 0.05 * z;
        float h = swell(w, t);
        float hx = swell(w + vec2(e, 0.0), t);
        float hz = swell(w + vec2(0.0, e), t);
        vec3 n = normalize(vec3(h - hx, e * 1.5, h - hz));
        float lam = clamp(dot(n, normalize(vec3(-0.3, 0.8, 0.4))), 0.0, 1.0);
        col = GFX_PRIMARY * (0.35 + 0.9 * lam);
        float foam = smoothstep(0.85, 1.15, h) * (0.6 + 0.4 * vnoise(w * 3.0 + t));
        col = mix(col, GFX_ACCENT * 0.8, foam * 0.7);
        col += GFX_ACCENT * bolt * 0.25;
        col = mix(col, GFX_SECONDARY, smoothstep(5.0, 30.0, z));
    }
    // Slanted rain.
    vec2 rq = vec2(p.x + p.y * 0.25, p.y) * vec2(90.0, 3.0) + vec2(0.0, t * 9.0);
    float rain = step(0.93, hash12(floor(rq))) * smoothstep(0.5, 0.0, abs(fract(rq.x) - 0.5));
    col += GFX_ACCENT * rain * 0.18 * P_RAIN;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
