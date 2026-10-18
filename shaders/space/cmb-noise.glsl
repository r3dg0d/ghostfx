// @id cmb-noise
// @name Cosmic Microwave Background
// @category space
// @description A Mollweide-style oval map of mottled temperature fluctuations, inspired by maps of the cosmic microwave background.
// @tags cmb, cosmology, map, science, noise
// @mode background
// @uses fbm
// @color PRIMARY #FF8A3D
// @color SECONDARY #07040A
// @color ACCENT #3D7BFF
// @limitation An artistic pattern made from fractal noise, not real CMB data.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec2 c = p - vec2(0.3, 0.0);
    vec2 e = c / vec2(0.62, 0.31);
    float inside = smoothstep(1.0, 0.985, length(e));
    // Map the ellipse onto a sphere-ish surface and rotate it slowly.
    float lat = asin(clamp(e.y, -1.0, 1.0));
    float lon = e.x * 3.1416 / max(cos(lat), 0.05) + t * 0.02;
    vec3 s = vec3(cos(lat) * cos(lon), sin(lat), cos(lat) * sin(lon));
    float n = fbm3(s * 6.0) * 0.6 + fbm3(s * 18.0 + 3.0) * 0.4;
    float tmp = (n - 0.5) * 2.2;
    vec3 cold = GFX_ACCENT, hot = GFX_PRIMARY;
    vec3 map = tmp > 0.0 ? mix(vec3(0.85, 0.75, 0.5), hot, clamp(tmp, 0.0, 1.0)) : mix(vec3(0.85, 0.75, 0.5), cold, clamp(-tmp, 0.0, 1.0));
    map *= 0.42;
    vec3 col = mix(GFX_SECONDARY, map, inside);
    col += vec3(0.6) * smoothstep(0.012, 0.0, abs(length(e) - 1.0)) * 0.4;
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
