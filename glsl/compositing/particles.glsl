// @module particles
// @requires hash
// Layered particle fields: one particle per grid cell, several parallax layers.

// Soft round particle intensity for the cell containing p.
// Returns brightness in .x and the per-particle random value in .y.
vec2 particle_cell(vec2 p, float size, float jitter) {
    vec2 id = floor(p);
    vec2 f = fract(p) - 0.5;
    vec2 h = hash22(id);
    vec2 o = (h - 0.5) * jitter;
    float d = length(f - o);
    float r = size * (0.4 + 0.6 * hash12(id + 7.3));
    float b = smoothstep(r, 0.0, d);
    return vec2(b * b, hash12(id + 3.1));
}

// Twinkle factor in [0,1] for a particle with random value r.
float twinkle(float r, float t) {
    return 0.55 + 0.45 * sin(t * (1.0 + 3.0 * r) + r * 40.0);
}
