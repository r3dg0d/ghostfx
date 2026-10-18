// @module lighting
// Cheap shading helpers for height-field "materials".

float fresnel_schlick(float cosTheta, float f0) {
    return f0 + (1.0 - f0) * pow(1.0 - clamp(cosTheta, 0.0, 1.0), 5.0);
}

// Normal from a scalar height field sampled by finite differences.
// Call with the three height samples h(p), h(p+dx), h(p+dy).
vec3 height_normal(float h, float hx, float hy, float eps, float strength) {
    return normalize(vec3((h - hx) * strength / eps, (h - hy) * strength / eps, 1.0));
}

float blinn(vec3 n, vec3 l, vec3 v, float shininess) {
    vec3 h = normalize(l + v);
    return pow(max(dot(n, h), 0.0), shininess);
}

// Procedural environment used for chrome-like reflections.
vec3 studio_env(vec3 r, vec3 sky, vec3 ground) {
    float y = r.y;
    vec3 c = mix(ground, sky, smoothstep(-0.2, 0.25, y));
    c += 1.2 * smoothstep(0.92, 1.0, sin(r.x * 3.0 + 1.3) * 0.5 + 0.5) * smoothstep(0.0, 0.6, y);
    c += 0.6 * exp(-40.0 * y * y);
    return c;
}
