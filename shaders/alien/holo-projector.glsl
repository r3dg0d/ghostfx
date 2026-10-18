// @id holo-projector
// @name Holo Projector
// @category alien
// @description A retro holographic projector beams a flickering, scanlined wireframe globe above its lens, rotating slowly.
// @tags hologram, projector, wireframe, globe, sci-fi, blue
// @mode background
// @uses hash
// @flashing true
// @color PRIMARY #5CC8FF
// @color SECONDARY #03060B
// @color ACCENT #E0F6FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 base = vec2(0.45, -0.4);
    vec3 col = GFX_SECONDARY;
    // Projection cone.
    vec2 q = p - base;
    float cone = smoothstep(0.0, 0.02, q.y) * smoothstep(q.y * 0.55 + 0.01, q.y * 0.5, abs(q.x)) * smoothstep(0.75, 0.3, q.y);
    col += GFX_PRIMARY * cone * 0.08;
    // Wireframe globe: latitude/longitude lines on a rotating sphere.
    vec2 c = p - vec2(0.45, 0.08);
    float R = 0.2;
    float r = length(c);
    if (r < R) {
        float z = sqrt(R * R - r * r);
        vec3 s = vec3(c, z) / R;
        float rot = t * 0.4;
        vec3 sr = vec3(s.x * cos(rot) + s.z * sin(rot), s.y, -s.x * sin(rot) + s.z * cos(rot));
        float lat = asin(clamp(sr.y, -1.0, 1.0));
        float lon = atan(sr.z, sr.x);
        float lines = smoothstep(0.06, 0.0, abs(fract(lat / 0.2618 + 0.5) - 0.5)) + smoothstep(0.06, 0.0, abs(fract(lon / 0.5236 + 0.5) - 0.5));
        col += GFX_PRIMARY * min(lines, 1.0) * (0.35 + 0.4 * s.z);
    }
    col += GFX_ACCENT * smoothstep(0.004, 0.0, abs(r - R)) * 0.5;
    // Scanlines + flicker over the hologram.
    float scan = 0.75 + 0.25 * sin(fragCoord.y / gfx_dpi() * 1.5 - t * 8.0);
    float flick = 1.0 - gfx_flash(0.3 * step(0.95, hash11(floor(t * 12.0))));
    col *= mix(1.0, scan * flick, smoothstep(R * 1.4, 0.0, r) + cone);
    col += GFX_ACCENT * exp(-length((p - base) * vec2(1.0, 4.0)) * 30.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
