// @id glass-prism
// @name Glass Prism
// @category glass
// @description A white beam enters a glass prism at the edge of the screen and fans out into a slowly turning rainbow.
// @tags prism, rainbow, light, glass, spectrum
// @mode background
// @uses sdf color
// @color PRIMARY #FFFFFF
// @color SECONDARY #07070C
// @color ACCENT #9AA7C7

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 pc = vec2(-0.45 * gfx_aspect() + 0.25, -0.05);
    vec2 q = p - pc;
    vec3 col = GFX_SECONDARY;

    // Incoming beam from the upper left.
    vec2 inDir = normalize(vec2(1.0, -0.35));
    vec2 rel = q + inDir * 0.0;
    float along = dot(rel, inDir);
    float across = abs(dot(rel, vec2(-inDir.y, inDir.x)));
    col += GFX_PRIMARY * smoothstep(0.012, 0.0, across) * step(along, 0.0) * 0.8;

    // Dispersed fan leaving the prism: hue varies with exit angle.
    float swing = 0.05 * sin(t * 0.2);
    float ang = atan(q.y, q.x) - swing;
    float spread = smoothstep(-0.32, -0.22, ang) * smoothstep(0.18, 0.08, ang) * step(0.0, q.x);
    float hue = clamp((ang + 0.27) / 0.4, 0.0, 1.0);
    vec3 rainbow = hsv2rgb(vec3(hue * 0.8, 0.85, 1.0));
    col += rainbow * spread * 0.55 * smoothstep(1.6, 0.1, length(q)) * smoothstep(0.08, 0.15, length(q));

    // The prism itself.
    float tri = sd_triangle(gfx_rot(0.1) * q, 0.12);
    col = mix(col, GFX_ACCENT * 0.25 + rainbow * 0.05, smoothstep(0.003, 0.0, tri) * 0.8);
    col += GFX_PRIMARY * smoothstep(0.004, 0.0, abs(tri)) * 0.7;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
