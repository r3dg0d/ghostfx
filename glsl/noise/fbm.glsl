// @module fbm
// @requires value gradient
// Fractal Brownian motion, ridged noise, turbulence and domain warping.
// Octave counts follow GFX_OCTAVES (set by the quality profile).

const mat2 GFX_FBM_ROT = mat2(0.80, 0.60, -0.60, 0.80);

float fbm(vec2 p) {
    float s = 0.0, a = 0.5;
    for (int i = 0; i < GFX_OCTAVES; i++) {
        s += a * vnoise(p);
        p = GFX_FBM_ROT * p * 2.02 + 17.1;
        a *= 0.5;
    }
    return s / (1.0 - pow(0.5, float(GFX_OCTAVES)));
}

float fbm3(vec3 p) {
    float s = 0.0, a = 0.5;
    for (int i = 0; i < GFX_OCTAVES; i++) {
        s += a * vnoise3(p);
        p = p * 2.03 + vec3(11.7, 3.1, 7.9);
        a *= 0.5;
    }
    return s / (1.0 - pow(0.5, float(GFX_OCTAVES)));
}

// Absolute-value gradient noise: billowy, fire- and smoke-like.
float turbulence(vec2 p) {
    float s = 0.0, a = 0.5;
    for (int i = 0; i < GFX_OCTAVES; i++) {
        s += a * abs(gnoise(p)) * 1.6;
        p = GFX_FBM_ROT * p * 2.03 + 5.3;
        a *= 0.5;
    }
    return s;
}

// Ridged multifractal: sharp crests (lightning, cracks, mountains).
float ridged(vec2 p) {
    float s = 0.0, a = 0.5, w = 1.0;
    for (int i = 0; i < GFX_OCTAVES; i++) {
        float n = 1.0 - abs(gnoise(p) * 1.6);
        n *= n * w;
        w = clamp(n * 1.5, 0.0, 1.0);
        s += a * n;
        p = GFX_FBM_ROT * p * 2.07 + 9.2;
        a *= 0.5;
    }
    return s;
}

// Two-level domain warp (Quilez-style technique). Returns the warped fbm and
// writes the intermediate warp vector for colouring.
float warped_fbm(vec2 p, float t, out vec2 q) {
    q = vec2(fbm(p + vec2(0.0, 0.0) + 0.12 * t), fbm(p + vec2(5.2, 1.3) - 0.10 * t));
    vec2 r = vec2(fbm(p + 3.5 * q + vec2(1.7, 9.2) + 0.15 * t),
                  fbm(p + 3.5 * q + vec2(8.3, 2.8) - 0.13 * t));
    return fbm(p + 3.0 * r);
}
