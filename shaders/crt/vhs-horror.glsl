// @id vhs-horror
// @name VHS Horror
// @category crt
// @description A found-footage tape: washed-out colour with a red cast, rolling noise, a blinking REC light and a timecode that keeps counting.
// @tags vhs, horror, found-footage, tape, retro, creepy
// @mode post
// @uses hash value crt
// @flashing true
// @distorts true
// @color PRIMARY #FF2A2A
// @color ACCENT #E8E8E8

// 3x5 digit font.
float digit(float d, vec2 g) {
    int font[10];
    font[0] = 31599; font[1] = 9362; font[2] = 29671; font[3] = 29391; font[4] = 23497;
    font[5] = 31183; font[6] = 31215; font[7] = 29257; font[8] = 31727; font[9] = 31695;
    int x = int(g.x), y = int(g.y);
    if (x < 0 || x > 2 || y < 0 || y > 4) return 0.0;
    return float((font[int(d)] >> ((4 - y) * 3 + (2 - x))) & 1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float wob = (vnoise(vec2(uv.y * 30.0, t * 2.0)) - 0.5) * 2.0 / iResolution.x * GFX_DISTORT_TEXT;
    vec2 suv = uv + vec2(wob, 0.0);
    vec4 term = gfx_term(suv);
    vec3 col = gfx_straight(term);
    float l = gfx_luma(col);
    col = mix(vec3(l), col, 0.45) * vec3(1.08, 0.92, 0.88);
    col += (hash12(fragCoord + floor(t * 24.0) * 31.0) - 0.5) * 0.08;
    float band = exp(-pow((uv.y - fract(-t * 0.07)) * 20.0, 2.0));
    col += band * 0.15 * hash12(vec2(floor(fragCoord.y / 2.0), floor(t * 24.0)));
    col *= vignette(uv, 0.7);
    // OSD: blinking REC dot + running timecode in the top-right corner.
    float px = 3.0 * gfx_dpi();
    vec2 o = vec2(iResolution.x - 34.0 * px, iResolution.y - 9.0 * px);
    vec2 g = floor((fragCoord - o) / px);
    float rec = step(length(fragCoord - o - vec2(-4.0, 2.5) * px), 2.2 * px) * step(0.5, fract(t * 0.5 * GFX_SPEED));
    float secs = floor(iTime);
    float osd = 0.0;
    for (int k = 0; k < 6; k++) {
        float fk = float(k);
        float val = k < 2 ? floor(secs / 3600.0) : k < 4 ? floor(mod(secs, 3600.0) / 60.0) : mod(secs, 60.0);
        float dgt = mod(floor(val / (mod(fk, 2.0) < 1.0 ? 10.0 : 1.0)), 10.0);
        osd = max(osd, digit(dgt, g - vec2(fk * 4.0 + floor(fk / 2.0) * 2.0, 0.0)));
    }
    col = mix(col, GFX_ACCENT, osd);
    col = mix(col, GFX_PRIMARY, gfx_flash(rec));
    fragColor = gfx_post_k(term, col, GFX_INTENSITY);
}
