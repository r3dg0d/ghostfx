// @id machinery
// @name Machinery
// @category metallic
// @description Interlocking gears turn at correct ratios in a dim engine room, their teeth catching the light.
// @tags gears, machinery, industrial, steampunk, mechanical
// @mode background
// @uses sdf
// @color PRIMARY #8A8F99
// @color SECONDARY #0B0C0E
// @color ACCENT #C98A3E

float gear(vec2 p, float r, float teeth, float ang) {
    p = gfx_rot(ang) * p;
    float a = atan(p.y, p.x);
    float tooth = smoothstep(-0.3, 0.3, sin(a * teeth)) * r * 0.12;
    float d = length(p) - (r + tooth);
    d = max(d, -(length(p) - r * 0.28));                   // axle hole
    // Spokes cut-outs.
    float sp = abs(sin(atan(p.y, p.x) * 3.0)) * length(p);
    float hole = max(length(p) - r * 0.75, -(length(p) - r * 0.4));
    d = max(d, -max(hole, -(sp - r * 0.12)));
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time() * 0.4;
    vec3 col = GFX_SECONDARY;
    // A chain of meshing gears: angular speed scales with 1/teeth.
    float r1 = 0.22, r2 = 0.14, r3 = 0.3;
    vec2 c1 = vec2(0.25, 0.05);
    vec2 c2 = c1 + vec2(r1 + r2 + 0.025, 0.08);
    vec2 c3 = c1 + vec2(-(r1 + r3 + 0.035), -0.12);
    float t1 = 16.0, t2 = 10.0, t3 = 22.0;
    float g1 = gear(p - c1, r1, t1, t);
    float g2 = gear(p - c2, r2, t2, -t * t1 / t2 + 0.3);
    float g3 = gear(p - c3, r3, t3, -t * t1 / t3 + 0.1);
    float d = min(g1, min(g2, g3));
    float fillm = smoothstep(0.002, -0.002, d);
    vec3 metal = mix(GFX_PRIMARY * 0.35, GFX_PRIMARY * 0.75, smoothstep(-0.5, 0.5, p.y));
    metal = mix(metal, GFX_ACCENT * 0.6, step(g3, min(g1, g2)) * 0.6);
    col = mix(col, metal, fillm);
    col += GFX_ACCENT * exp(-abs(d) * 300.0) * 0.25 * fillm;
    col += vec3(0.8) * smoothstep(0.004, 0.0, abs(d)) * 0.15;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
