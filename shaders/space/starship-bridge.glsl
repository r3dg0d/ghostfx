// @id starship-bridge
// @name Starship Bridge
// @category space
// @description The view from a starship bridge: stars stream past a wide viewport framed by struts, with console lights blinking below.
// @tags starship, bridge, sci-fi, stars, viewport
// @mode background
// @uses hash sdf
// @color PRIMARY #CFE3FF
// @color SECONDARY #020309
// @color ACCENT #FF9A3D

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Streaming stars in radial lanes (integer lane count: no seam).
    vec2 c = p - vec2(0.0, 0.08);
    float r = length(c);
    float a = atan(c.y, c.x);
    float lanes = 140.0;
    float lane = floor((a / 6.2831 + 0.5) * lanes);
    float la = fract((a / 6.2831 + 0.5) * lanes) - 0.5;
    for (int k = 0; k < 2; k++) {
        float fk = float(k);
        float h = hash12(vec2(lane, fk));
        float z = fract(h * 13.0 + t * (0.05 + 0.08 * h));
        float head = 0.04 + z * z * 1.2;
        float len = 0.01 + z * z * 0.12;
        float seg = smoothstep(head - len, head, r) * step(r, head);
        float w = smoothstep(0.5, 0.0, abs(la) * r * lanes * 0.15);
        col += GFX_PRIMARY * seg * w * step(0.55, hash12(vec2(lane, fk + 5.0))) * (0.3 + z);
    }
    // Viewport frame: top and bottom bulkheads plus two angled struts.
    float topEdge = 0.42 - 0.06 * abs(p.x);
    float sillEdge = -0.3 + 0.03 * abs(p.x);
    float strutX = abs(p.x) - (0.5 * gfx_aspect() * 0.6 + (p.y - 0.05) * 0.18);
    float frame = max(max(step(topEdge, p.y), step(p.y, sillEdge)), smoothstep(0.004, 0.0, abs(strutX) - 0.015));
    col = mix(col, vec3(0.03, 0.032, 0.04) + 0.02 * (p.y - sillEdge), frame);
    col += GFX_PRIMARY * 0.15 * smoothstep(0.004, 0.0, abs(p.y - topEdge)) + GFX_PRIMARY * 0.1 * smoothstep(0.004, 0.0, abs(p.y - sillEdge));
    // Console lights along the sill.
    vec2 g = vec2(p.x * 40.0, (p.y + 0.4) * 30.0);
    vec2 id = floor(g);
    float light = step(0.6, hash12(id)) * smoothstep(0.25, 0.1, length(fract(g) - 0.5)) * step(p.y, sillEdge - 0.02);
    float blink = step(0.3, hash12(id + floor(t * (0.5 + hash12(id) * 2.0))));
    col += mix(GFX_ACCENT, vec3(0.3, 0.8, 1.0), step(0.7, hash12(id + 3.0))) * light * blink * 0.8;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
