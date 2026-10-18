// @module color
// Colour utilities: cosine palettes, HSV, tonemapping, blackbody.

// Cosine gradient palette: a + b * cos(2pi * (c * t + d)).
vec3 cospal(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}

// Narkowicz's fitted ACES filmic curve.
vec3 tonemap_aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec3 tonemap_reinhard(vec3 x) { return x / (1.0 + x); }

vec3 gamma_encode(vec3 c) { return pow(max(c, 0.0), vec3(1.0 / 2.2)); }
vec3 gamma_decode(vec3 c) { return pow(max(c, 0.0), vec3(2.2)); }

// Approximate blackbody colour for t in [0, 1] (cold ember -> white hot).
vec3 blackbody(float t) {
    t = clamp(t, 0.0, 1.0);
    return vec3(1.0, 0.35, 0.05) * smoothstep(0.0, 0.45, t) +
           vec3(0.0, 0.55, 0.30) * smoothstep(0.35, 0.8, t) +
           vec3(0.0, 0.10, 0.65) * smoothstep(0.7, 1.0, t);
}

// Three-stop ramp through the preset colours.
vec3 ramp3(float t, vec3 a, vec3 b, vec3 c) {
    t = clamp(t, 0.0, 1.0);
    return t < 0.5 ? mix(a, b, t * 2.0) : mix(b, c, t * 2.0 - 2.0 * 0.5);
}

// Thin-film style iridescence.
vec3 iridescence(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}
