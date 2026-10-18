// @id keyboard-glow
// @name Keyboard Glow
// @category cyberpunk
// @description A holographic keyboard glows along the bottom of the window, keys lighting up in ripples every time you type.
// @tags keyboard, hologram, typing, reactive, rgb, cursor
// @mode background
// @uses hash sdf color
// @color PRIMARY #3DE0FF
// @color SECONDARY #04050A
// @color ACCENT #FF3DD2
// @limitation Reacts to cursor movement (Ghostty 1.2+), which is the closest proxy for key presses a shader can see.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;
    // Perspective keyboard in the lower quarter.
    float top = -0.22;
    if (p.y < top) {
        float dy = top - p.y;
        float z = 0.08 / (dy + 0.04);
        vec2 k = vec2(p.x * z * 6.0, z * 3.0);
        float row = floor(k.y);
        k.x += row * 0.35;                               // staggered rows
        vec2 id = floor(k);
        vec2 f = fract(k) - 0.5;
        float key = smoothstep(0.02, -0.02, sd_box(f, vec2(0.4, 0.38)) - 0.04);
        // Typing ripple from a key derived from the cursor column.
        float age = gfx_cursor_age();
        float cx = gfx_cursor_center().x / iResolution.x;
        vec2 src = vec2(floor((cx - 0.5) * 30.0), 1.0);
        float dist = length(id - src);
        float ripple = exp(-pow(dist - age * 18.0, 2.0) * 0.3) * exp(-age * 1.5);
        float idle = 0.15 + 0.1 * sin(t + id.x * 0.4 + id.y);
        vec3 rgb = hsv2rgb(vec3(fract(id.x * 0.03 + t * 0.05), 0.7, 1.0));
        col += mix(GFX_PRIMARY, rgb, 0.5) * key * (idle + ripple * 1.5) * smoothstep(0.0, 0.08, dy) * 0.8;
        col += GFX_ACCENT * key * exp(-dist * 1.5) * exp(-age * 4.0);
    }
    col += GFX_PRIMARY * 0.12 * exp(-abs(p.y - top) * 40.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
