// @id crt-vhs
// @name CRT VHS
// @category crt
// @description Worn videotape playback: bleeding colour, wobbling lines, tape noise and a tracking band drifting up the screen.
// @tags vhs, tape, retro, analog, 80s
// @mode post
// @uses crt hash value
// @distorts true
// @param TRACKING float 1.0 0.0 2.0 Tracking band strength
// @param BLEED float 1.0 0.0 2.0 Colour bleed width

vec3 rgb2yiq(vec3 c) {
    return vec3(dot(c, vec3(0.299, 0.587, 0.114)), dot(c, vec3(0.596, -0.274, -0.322)), dot(c, vec3(0.211, -0.523, 0.312)));
}
vec3 yiq2rgb(vec3 c) {
    return vec3(c.x + 0.956 * c.y + 0.621 * c.z, c.x - 0.272 * c.y - 0.647 * c.z, c.x - 1.106 * c.y + 1.703 * c.z);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    vec4 term = gfx_term(uv);

    // Line wobble and the tracking band.
    float wob = (vnoise(vec2(uv.y * 40.0, t * 3.0)) - 0.5) * 1.5 / iResolution.x;
    float bandY = fract(t * 0.05);
    float band = exp(-pow((uv.y - bandY) * 30.0, 2.0)) * P_TRACKING;
    wob += band * (hash12(vec2(floor(fragCoord.y / 2.0), floor(t * 30.0))) - 0.5) * 0.03;
    vec2 suv = uv + vec2(wob * GFX_DISTORT_TEXT, 0.0);

    // Sharp luma, smeared chroma.
    vec3 yiq = rgb2yiq(gfx_straight(gfx_term(suv)));
    vec2 chroma = vec2(0.0);
    float bw = 2.5 * P_BLEED * gfx_dpi() / iResolution.x;
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        chroma += rgb2yiq(gfx_straight(gfx_term(suv - vec2(bw * fi, 0.0)))).yz;
    }
    yiq.yz = chroma / 6.0 * 0.85;
    vec3 col = yiq2rgb(yiq);

    float noise = hash12(fragCoord + floor(t * 30.0) * 17.0);
    col += (noise - 0.5) * 0.06;
    col += band * noise * 0.25;
    col *= scanline(fragCoord.y, 1.0 / (2.0 * gfx_dpi()), 0.2);
    col *= vignette(uv, 0.3);
    fragColor = gfx_post(term, col);
}
