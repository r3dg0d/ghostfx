// @id chrome
// @name Chrome
// @category metallic
// @description A slab of mirror-polished chrome with embossed ripples, reflecting a high-contrast sky and dark horizon.
// @tags chrome, metal, reflection, retro, silver
// @mode background
// @uses gradient lighting
// @color PRIMARY #DCE8FF
// @color SECONDARY #121318
// @color ACCENT #4B5A7A

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    float h = 0.15 * sin(p.x * 4.0 + sin(p.y * 3.0 + t * 0.2)) + 0.08 * gnoise(p * 3.0 + t * 0.05);
    vec2 g = vec2(0.6 * cos(p.x * 4.0 + sin(p.y * 3.0 + t * 0.2)), 0.36 * cos(p.y * 3.0 + t * 0.2) * cos(p.x * 4.0));
    vec3 n = normalize(vec3(-g, 1.0));
    vec3 r = reflect(vec3(0.0, 0.0, -1.0), n);
    // Classic chrome environment: bright sky, hard dark horizon, warm ground.
    float y = r.y + 0.15 * sin(t * 0.1);
    vec3 sky = mix(GFX_PRIMARY * 0.75, GFX_PRIMARY, smoothstep(0.0, 0.6, y));
    vec3 ground = mix(GFX_SECONDARY, GFX_ACCENT * 0.7, smoothstep(-0.8, 0.0, y));
    vec3 col = y > 0.0 ? sky : ground;
    col *= 0.85 + 0.15 * h;
    col += vec3(1.0) * smoothstep(0.02, 0.0, abs(y)) * 0.3;
    fragColor = gfx_compose(uv, gfx_term(uv), col * 0.8);
}
