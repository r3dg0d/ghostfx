// @id glitch-rain
// @name Glitch Rain
// @category glitch
// @description Shards of colour-split static fall like rain behind the text, each fragment flickering as it drops.
// @tags glitch, rain, shards, rgb, digital
// @mode background
// @uses hash
// @color PRIMARY #FF2E63
// @color SECONDARY #06060A
// @color ACCENT #08D9D6

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    vec2 p = gfx_p(fragCoord);
    float t = gfx_time();
    vec3 col = GFX_SECONDARY;

    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float cw = 0.035 + 0.02 * fi;
        float cid = floor(p.x / cw);
        float h = hash11(cid * 1.31 + fi * 7.0);
        float speed = 0.3 + 0.5 * h;
        float y = p.y + t * speed + h * 5.0;
        float sid = floor(y / 0.18);
        float fy = fract(y / 0.18);
        float hs = hash12(vec2(cid, sid + fi * 31.0));
        if (hs > 0.25) continue;
        float len = 0.2 + 0.6 * hash12(vec2(sid, cid));
        float lx = fract(p.x / cw);
        float shard = step(fy, len) * step(0.1, lx) * step(lx, 0.9);
        // Internal static and a per-shard RGB split.
        float st = hash12(floor(vec2(lx * 6.0, fy * 20.0)) + sid + floor(t * 12.0));
        vec3 c = vec3(st * step(0.3, lx), st * 0.5, st * step(lx, 0.7));
        c = mix(c, mix(GFX_PRIMARY, GFX_ACCENT, hs * 4.0), 0.6);
        col += c * shard * (0.5 - fi * 0.12) * (1.0 - fy / len);
    }
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
