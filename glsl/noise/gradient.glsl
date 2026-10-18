// @module gradient
// @requires hash
// Gradient (Perlin-style) noise, range roughly [-0.7, 0.7].

vec2 gfx_grad(vec2 i) {
    float a = hash12(i) * 6.2831853;
    return vec2(cos(a), sin(a));
}

float gnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float a = dot(gfx_grad(i), f);
    float b = dot(gfx_grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(gfx_grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(gfx_grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
