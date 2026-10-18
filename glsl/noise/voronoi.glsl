// @module voronoi
// @requires hash
// Animated cellular noise. Returns vec3(F1, F2, cell id hash).

vec3 voronoi(vec2 p, float t) {
    vec2 n = floor(p), f = fract(p);
    float f1 = 8.0, f2 = 8.0, id = 0.0;
    for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++) {
        vec2 g = vec2(float(i), float(j));
        vec2 h = hash22(n + g);
        vec2 o = 0.5 + 0.5 * sin(t + 6.2831 * h);
        float d = length(g + o - f);
        if (d < f1) { f2 = f1; f1 = d; id = hash12(n + g); }
        else if (d < f2) { f2 = d; }
    }
    return vec3(f1, f2, id);
}

// Distance to the nearest cell border (two-pass, exact edges).
float voronoi_edge(vec2 p, float t) {
    vec2 n = floor(p), f = fract(p);
    vec2 mg = vec2(0.0), mr = vec2(0.0);
    float md = 8.0;
    for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++) {
        vec2 g = vec2(float(i), float(j));
        vec2 o = 0.5 + 0.5 * sin(t + 6.2831 * hash22(n + g));
        vec2 r = g + o - f;
        float d = dot(r, r);
        if (d < md) { md = d; mr = r; mg = g; }
    }
    md = 8.0;
    for (int j = -2; j <= 2; j++)
    for (int i = -2; i <= 2; i++) {
        vec2 g = mg + vec2(float(i), float(j));
        vec2 o = 0.5 + 0.5 * sin(t + 6.2831 * hash22(n + g));
        vec2 r = g + o - f;
        if (dot(mr - r, mr - r) > 0.00001)
            md = min(md, dot(0.5 * (mr + r), normalize(r - mr)));
    }
    return md;
}
