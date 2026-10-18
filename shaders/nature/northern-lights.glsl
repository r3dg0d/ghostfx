// @id northern-lights
// @name Northern Lights
// @category nature
// @description Green and violet aurora curtains ripple across a starry sky above a silhouetted pine forest.
// @tags aurora, northern-lights, night, green, sky, nature
// @mode background
// @uses fbm hash
// @color PRIMARY #3DFF9A
// @color SECONDARY #020814
// @color ACCENT #B05CFF
// @param HEIGHT float 0.35 0.1 0.6 Height of the aurora base above the horizon

float pine_line(float x) {
    // Saw-tooth pine tops of varying height.
    float id = floor(x * 18.0);
    float f = fract(x * 18.0);
    float h = 0.04 + 0.06 * hash11(id);
    return h * (1.0 - abs(f - 0.5) * 2.0) + 0.02 * vnoise(vec2(x * 5.0, 0.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = mix(GFX_SECONDARY * 1.8, GFX_SECONDARY, smoothstep(-0.4, 0.5, p.y));
    vec2 sg = p * 80.0;
    float sh = hash12(floor(sg));
    col += vec3(0.85) * step(0.988, sh) * smoothstep(0.3, 0.0, length(fract(sg) - 0.5)) * (0.6 + 0.4 * sin(t * 2.0 + sh * 30.0));

    // Curtains: a wavy base line with tall vertical rays rising from it.
    float base = -0.5 + P_HEIGHT + 0.08 * fbm(vec2(p.x * 1.2 + t * 0.04, t * 0.05));
    float h = p.y - base;
    float rays = fbm(vec2(p.x * 22.0 + 3.0 * fbm(vec2(p.x * 2.0, t * 0.1)), t * 0.2));
    float curtain = smoothstep(-0.02, 0.02, h) * exp(-max(h, 0.0) * (3.5 - rays * 1.5));
    float intensity = curtain * pow(rays, 1.5) * 1.8;
    vec3 ac = mix(GFX_PRIMARY, GFX_ACCENT, smoothstep(0.05, 0.4, h));
    col += ac * intensity;
    col += GFX_PRIMARY * 0.08 * exp(-abs(h) * 6.0);
    // Forest silhouette.
    float tree = -0.42 + pine_line(p.x);
    col = mix(col, vec3(0.0, 0.01, 0.015), smoothstep(0.002, -0.002, p.y - tree));
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
