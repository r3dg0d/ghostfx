// @module distortion
// Coordinate transforms: polar, swirl, barrel, kaleidoscope.

vec2 to_polar(vec2 p) { return vec2(length(p), atan(p.y, p.x)); }

vec2 swirl(vec2 p, float amount, float radius) {
    float r = length(p);
    float a = amount * smoothstep(radius, 0.0, r);
    return gfx_rot(a) * p;
}

// Barrel distortion in 0..1 uv space (CRT curvature).
vec2 barrel(vec2 uv, float k) {
    vec2 c = uv * 2.0 - 1.0;
    c *= 1.0 + k * dot(c, c);
    return c * 0.5 + 0.5;
}

// Fold the plane into n mirrored wedges.
vec2 kaleido(vec2 p, float n) {
    float a = atan(p.y, p.x), r = length(p);
    float w = 6.28318 / n;
    a = mod(a, w);
    a = abs(a - 0.5 * w);
    return r * vec2(cos(a), sin(a));
}

// Uv outside [0,1] mask, used for curved screens.
float inside01(vec2 uv) {
    vec2 s = step(vec2(0.0), uv) * step(uv, vec2(1.0));
    return s.x * s.y;
}
