// @id copper-metal
// @name Copper Metal
// @category metallic
// @description Hammered copper: dimpled facets glint with warm light, with verdigris patina settling into the seams.
// @tags copper, metal, hammered, patina, warm
// @mode background
// @uses voronoi value lighting hash
// @color PRIMARY #D7743F
// @color SECONDARY #1E0D06
// @color ACCENT #3FB8A0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord) * 6.0;
    float t = gfx_time();
    vec3 v = voronoi(p, 0.0);
    // Each hammer dimple is a shallow sphere: the normal tilts away from the
    // nearest cell centre, found with a small local search.
    vec2 ip = floor(p), fp = fract(p);
    vec2 best = vec2(0.0);
    float bd = 8.0;
    for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++) {
        vec2 g = vec2(float(i), float(j));
        vec2 r = g + 0.5 + 0.5 * sin(6.2831 * hash22(ip + g)) - fp;
        float dd = dot(r, r);
        if (dd < bd) { bd = dd; best = r; }
    }
    vec3 n = normalize(vec3(-best * 1.2, 1.0));
    vec3 l = normalize(vec3(cos(t * 0.15), sin(t * 0.12), 0.8));
    float diff = max(dot(n, l), 0.0);
    float spec = blinn(n, l, vec3(0.0, 0.0, 1.0), 40.0);
    vec3 col = GFX_SECONDARY + GFX_PRIMARY * diff * 0.6 + vec3(1.0, 0.8, 0.6) * spec * 0.5;
    float seam = 1.0 - smoothstep(0.0, 0.1, v.y - v.x);
    float patina = seam * smoothstep(0.4, 0.8, vnoise(p * 0.7));
    col = mix(col, GFX_ACCENT * 0.5, patina * 0.8);
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
