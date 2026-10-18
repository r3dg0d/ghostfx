# Writing a GhostFX shader

A shader is one file, `shaders/<category>/<id>.glsl`: a metadata header of
`// @key value` lines, followed by a Shadertoy-style `mainImage`. The build
inlines the GLSL library modules it asks for and prepends its parameters as
`#define`s, producing a standalone file Ghostty can load.

```glsl
// @id ender-portal                         kebab-case, must equal the file name
// @name Ender Portal
// @category minecraft                      directory name; see `ghostfx categories`
// @description Parallax layers of ...      one or two sentences, >= 40 characters
// @tags portal, purple, space              comma separated
// @mode background                         background | glow | overlay | post | distort
// @uses hash particles                     GLSL modules from glsl/ (dependencies resolve automatically)
// @color PRIMARY #8B5CF6                   PRIMARY / SECONDARY / ACCENT (BACKGROUND/FOREGROUND for legacy builds)
// @param DEPTH float 1.0 0.3 2.0 Parallax depth between layers
// @preset cinematic DEPTH=1.5              per-preset overrides (also new preset names)
// @flashing true                           has flashes: must use gfx_flash() / GFX_REDUCED_FLASH
// @distorts true                           moves text: must use gfx_text_offset() / GFX_DISTORT_TEXT
// @animated false                          static effect (default true)
// @limitation No previous-frame feedback, so ...
// @inspired Minecraft's End portal (original procedural interpretation, no game assets)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = gfx_uv(fragCoord);      // 0..1 for texture lookups
    vec2 p  = gfx_p(fragCoord);       // aspect-correct, y in [-0.5, 0.5]
    float t = gfx_time();             // speed / reduced-motion aware
    vec3 col = ...;                   // your effect, in display (sRGB) space
    fragColor = gfx_compose(uv, gfx_term(uv), col);
}
```

`@param` becomes `#define P_<NAME>`; common parameters are `GFX_<NAME>`:

| Define | Meaning |
|---|---|
| `GFX_INTENSITY` | how strongly the effect replaces the background / is applied |
| `GFX_SPEED`, `GFX_REDUCED_MOTION` | folded into `gfx_time()` |
| `GFX_BRIGHTNESS`, `GFX_SATURATION` | applied by the compose helpers |
| `GFX_READABILITY` | luminance cap + halo behind glyphs |
| `GFX_REDUCED_FLASH` | `gfx_flash(x)` scales flashes to 20% |
| `GFX_DISTORT_TEXT` | 0 = text never moves (`gfx_text_offset()` returns 0) |
| `GFX_QUALITY` | 0/1/2 → `GFX_OCTAVES`, `GFX_STEPS`, `GFX_LAYERS` |
| `GFX_PRIMARY`, `GFX_SECONDARY`, `GFX_ACCENT` | `vec3` colours from the preset/palette |

## Compositing modes

* `gfx_compose(uv, term, fx)`: **background**. The effect replaces the
  terminal background; glyphs and coloured cells stay on top, untouched.
* `gfx_overlay(uv, term, light)`: additive light over everything, dimmed over glyphs.
* `gfx_compose_glow(uv, term, fx, light)`: both.
* `gfx_post(term, col)`: full-frame filters (CRT, colour). `col` is the
  processed image; intensity cross-fades with the original.
* `gfx_post_k(base, col, k)`: like `gfx_post` for effects that **move
  pixels**; pass the terminal sampled at the displaced position as `base` so
  the cross-fade never shows a ghost double image.

Always sample the terminal through `gfx_term()` (it handles colour spaces) and
finish through one of the helpers above (they handle readability, grading,
alpha and output encoding).

## Rules

* No `#version`, `main()`, `#include`, `iChannel1-3`; avoid `iMouse`/`iDate`
  (Ghostty does not update them). `ghostfx validate` enforces this.
* Code must compile as GLSL 4.30 **and** GLSL ES 3.00 (the gallery): no
  implicit int→float conversion, no reserved words (`active`, `sample`,
  `filter`, `input`, `output`, `common`, `partition`).
* Avoid `atan()` seams: when noise is sampled around a centre, use a
  direction vector or a swirled Cartesian coordinate instead of the angle.
* Keep loops bounded by constants or `GFX_*`/`P_*` defines.
* Defaults must keep text readable: aim for a measured contrast of at least
  4.5:1 (`ghostfx generate-previews` reports it).

## Workflow

```sh
python3 -m ghostfx validate shaders/space/my-shader.glsl     # Ghostty's compile chain
python3 -m ghostfx preview my-shader --out /tmp/p.png        # offscreen render
python3 -m ghostfx preview my-shader --window                # real Ghostty window
python3 -m ghostfx generate-previews my-shader               # thumbnail + verification record
python3 -m ghostfx build --all --preset-files --manifest     # refresh dist/, presets/, manifest.json
pytest -q
```
