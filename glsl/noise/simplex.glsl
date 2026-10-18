// @module simplex
// @requires hash
// 2D simplex noise using a hashed gradient lattice, range about [-1, 1].
// Skewing constants follow Gustavson's description of the algorithm.

float snoise(vec2 v) {
    const float F2 = 0.36602540378; // (sqrt(3)-1)/2
    const float G2 = 0.21132486540; // (3-sqrt(3))/6
    vec2 i = floor(v + dot(v, vec2(F2)));
    vec2 x0 = v - i + dot(i, vec2(G2));
    vec2 o = x0.x > x0.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 x1 = x0 - o + G2;
    vec2 x2 = x0 - 1.0 + 2.0 * G2;
    vec3 h = max(0.5 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0);
    h = h * h * h * h;
    vec2 g0 = hash22(i) * 2.0 - 1.0;
    vec2 g1 = hash22(i + o) * 2.0 - 1.0;
    vec2 g2 = hash22(i + 1.0) * 2.0 - 1.0;
    vec3 n = h * vec3(dot(g0, x0), dot(g1, x1), dot(g2, x2));
    return 90.0 * (n.x + n.y + n.z);
}
