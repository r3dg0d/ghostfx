// @id mirror-dimension
// @name Mirror Dimension
// @category glass
// @description An infinity mirror: nested frames recede into the distance, each reflection a little dimmer and tinted, slowly rotating.
// @tags mirror, infinity, recursion, frames, surreal
// @mode background
// @uses sdf
// @color PRIMARY #B8A6FF
// @color SECONDARY #050409
// @color ACCENT #6BE6FF

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.35, 0.0);
    vec3 col = GFX_SECONDARY;
    // Each reflection is the frame scaled by 0.8 and turned slightly.
    float scale = 1.0;
    vec2 q = c;
    for (int i = 0; i < 12; i++) {
        float fi = float(i);
        float d = sd_box(q, vec2(0.36, 0.22)) ;
        float edge = smoothstep(0.006 * scale, 0.0, abs(d) * scale);
        float fade = pow(0.8, fi);
        col += mix(GFX_PRIMARY, GFX_ACCENT, fract(fi * 0.15 + t * 0.02)) * edge * fade * 0.8;
        q = gfx_rot(0.06 * sin(t * 0.2) + 0.03) * q / 0.8;
        scale *= 0.8;
    }
    col += GFX_ACCENT * 0.05 * exp(-length(c) * 6.0);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
