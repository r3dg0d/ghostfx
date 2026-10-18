// @id hacker-terminal
// @name Hacker Terminal
// @category matrix
// @description A dark ops console: faint scanlines, a slowly rolling scan bar, hex readouts ghosting in the margins and a phosphor glow on the text.
// @tags hacker, terminal, green, subtle, scanlines
// @mode glow
// @uses hash crt
// @color PRIMARY #39FF88
// @color SECONDARY #020604
// @color ACCENT #0F4D2C

// 3x5 hex digit font, 0-F.
float hexdigit(float d, vec2 g) {
    int font[16];
    font[0] = 31599; font[1] = 9362; font[2] = 29671; font[3] = 29391;
    font[4] = 23497; font[5] = 31183; font[6] = 31215; font[7] = 29257;
    font[8] = 31727; font[9] = 31695; font[10] = 11245; font[11] = 27566;
    font[12] = 31015; font[13] = 27502; font[14] = 31143; font[15] = 31140;
    int x = int(g.x), y = int(g.y);
    if (x < 0 || x > 2 || y < 0 || y > 4) return 0.0;
    int bits = font[int(d)];
    return float((bits >> ((4 - y) * 3 + (2 - x))) & 1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 fx = GFX_SECONDARY;
    // Hex dump columns in the right margin, updating a few times a second.
    float px = 3.0 * gfx_dpi();
    vec2 cell = floor(fragCoord / (px * vec2(4.0, 7.0)));
    vec2 g = floor(mod(fragCoord / px, vec2(4.0, 7.0)));
    float margin = step(0.78, uv.x);
    float d = floor(hash12(cell + floor(t * 3.0 * hash12(cell.yy))) * 16.0);
    float bit = hexdigit(d, vec2(g.x, 6.0 - g.y - 1.0));
    float rowOn = step(0.4, hash12(vec2(cell.y, floor(t * 0.5))));
    fx += GFX_ACCENT * bit * margin * rowOn * 1.6;
    fx *= scanline(fragCoord.y, 1.0 / (3.0 * gfx_dpi()), 0.4);
    float bar = exp(-pow((fract(uv.y - t * 0.05) - 0.5) * 10.0, 2.0));
    fx += GFX_ACCENT * bar * 0.15;
    // Phosphor glow on the terminal text.
    vec3 glow_ = max(term_bloom(uv, 3.0) - GFX_TERM_BG, 0.0);
    vec3 light = GFX_PRIMARY * gfx_luma(glow_) * 0.35;
    fragColor = gfx_compose_glow(uv, gfx_term(uv), fx, light);
}
