// @id screen-tear
// @name Screen Tear
// @category glitch
// @description A vsync failure: a tear line sweeps down the screen, with the image above it sheared sideways.
// @tags glitch, tear, vsync, displacement
// @mode post
// @uses hash
// @distorts true
// @param SHEAR float 0.02 0.0 0.1 Horizontal offset above the tear (fraction of width)
// @param SPEED_TEAR float 0.3 0.05 1.5 Tear sweep speed
// @preset subtle SHEAR=0.006

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);
    float t = gfx_time();
    float cycle = floor(t * P_SPEED_TEAR);
    float tear = 1.0 - fract(t * P_SPEED_TEAR);
    float above = step(tear, uv.y);
    float sh = (hash11(cycle) - 0.5) * 2.0 * P_SHEAR * GFX_DISTORT_TEXT * GFX_INTENSITY;
    vec2 suv = vec2(fract(uv.x + sh * above), uv.y);
    vec4 term = gfx_term(suv);
    vec3 col = gfx_straight(term);
    float edge = exp(-abs(uv.y - tear) * iResolution.y / (1.5 * gfx_dpi()));
    col += vec3(0.25) * edge * GFX_INTENSITY;
    fragColor = gfx_post_k(term, col, 1.0);
}
