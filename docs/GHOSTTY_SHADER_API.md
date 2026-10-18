# Ghostty's custom-shader interface (as implemented, Ghostty 1.3.x)

Everything below was established from Ghostty's source
(`src/renderer/shadertoy.zig`, `src/renderer/generic.zig`,
`src/renderer/shaders/shadertoy_prefix.glsl`, `src/config/Config.zig`) at tags
v1.2.3 and v1.3.1 and `main` (October 2026), and confirmed by running Ghostty
1.3.1 (nixpkgs build) under Xvfb with Mesa llvmpipe.

## 1. Loading

* `custom-shader = <path>` in the config; repeatable. Shaders run **in the
  order listed**, each pass reading the previous pass's output (a front/back
  texture swap chain). The last pass writes the window.
* `custom-shader` can also be passed on the command line
  (`ghostty --custom-shader=/path.glsl`), which `ghostfx preview --window` uses.
* A missing file is an error unless written as `?path` (optional).
* Changes apply on config reload (no restart needed). On Linux/GTK Ghostty
  reloads its config on **SIGUSR2**; macOS uses the "Reload Configuration"
  menu item / `cmd+shift+,`. There is no file-watch hot reload.

## 2. Language and entry point

* The file is a Shadertoy-style fragment: it must define
  `void mainImage(out vec4 fragColor, in vec2 fragCoord)`.
* Ghostty prepends its prefix (`#version 430 core`, the uniform block,
  `iChannel0`, and a `main()` that calls `mainImage`). So shaders must **not**
  contain `#version`, `main()` or `#include` (there is no include support).
* The combined source is compiled by glslang to **SPIR-V 1.5 for Vulkan 1.2**,
  then SPIRV-Cross converts it to **GLSL 4.30** (OpenGL renderer, Linux) or
  **MSL** (Metal renderer, macOS). Any shader GhostFX ships passes exactly this
  chain in `ghostfx validate`.
* `texture2D` is `#define`d to `texture`. `fragCoord` has its origin at the
  bottom-left, like Shadertoy.

## 3. Uniforms (std140 block `Globals`, binding 1)

| Uniform | Status in Ghostty |
|---|---|
| `vec3 iResolution` | framebuffer size in **physical pixels** (HiDPI aware) |
| `float iTime`, `iTimeDelta`, `int iFrame` | updated every frame |
| `float iFrameRate` | **constant 60** |
| `float iChannelTime[4]`, `vec4 iDate`, `float iSampleRate` | **not updated** (0) |
| `vec3 iChannelResolution[4]` | `[0]` = terminal texture size |
| `vec4 iMouse` | **always zero** — Ghostty does not expose the mouse |
| `vec4 iCurrentCursor`, `iPreviousCursor`, `iCurrentCursorColor`, `iPreviousCursorColor`, `float iTimeCursorChange` | cursor rect/colours (since 1.2) |
| `int iCurrentCursorStyle`, `iPreviousCursorStyle`, `iCursorVisible`, `float iTimeFocus`, `int iFocus`, `vec3 iPalette[256]`, `iBackgroundColor`, `iForegroundColor`, `iCursorColor`, `iCursorText`, `iSelectionForegroundColor`, `iSelectionBackgroundColor` | **since 1.3** |

GhostFX targets 1.3+ because it uses `iBackgroundColor`/`iForegroundColor`
to separate glyphs from background. `--legacy` builds replace them with the
palette colours from the preset, and focus uniforms with constants, so they
compile against the 1.2 prefix too.

## 4. Textures

* Only `iChannel0` exists: the rendered terminal (or the previous shader in
  the chain). `iChannel1..3` are not bound.
* There is **no previous-frame feedback**: each frame the terminal is
  re-rendered into the texture. Effects that need persistence (phosphor
  afterglow, trails, accumulation, cellular automata) must be approximated
  analytically. GhostFX documents each such approximation.
* No access to the desktop, wallpaper or windows behind Ghostty. "Glass"
  shaders therefore use procedural backdrops.

## 5. Colour space (important, and easy to get wrong)

`alpha-blending` decides what the shader sees:

* `linear` / `linear-corrected` (default on Linux): `iChannel0` holds
  **linear** colour, and the shader output is **sRGB-encoded by the
  framebuffer**. Measured: outputting `iBackgroundColor` (#282c34) directly
  shows up as (110,115,125) on screen.
* `native` (default on macOS): everything is display-encoded; values pass
  through unchanged.

The colour uniforms (`iBackgroundColor`, palette, …) are always sRGB values.
GhostFX works in display space and converts at the edges
(`gfx_term()` decodes, `gfx_output()` encodes). `GFX_COLORSPACE` selects
native/linear explicitly; `0` (used by the pre-built `dist/` files)
auto-detects by comparing edge samples with `iBackgroundColor` in both
encodings, falling back to linear when the background is pure black/white.
`ghostfx apply` reads your `alpha-blending` and builds for it exactly.

## 6. Transparency

The terminal texture is premultiplied; with `background-opacity < 1`
background pixels have alpha < 1. GhostFX un-premultiplies, composites, and
writes premultiplied output whose alpha is raised by `GFX_OPACITY ×
GFX_INTENSITY` where the effect is drawn.

## 7. Animation and power

`custom-shader-animation`:

* `true` (default): an animation loop runs **only while the surface is
  focused**. Unfocused terminals redraw only when their content changes, so
  `iTime` jumps; Ghostty exposes `iFocus`/`iTimeFocus` so shaders can react.
* `always`: animate even when unfocused (more CPU/GPU).
* `false`: render only on terminal updates (no animation).

Ghostty's docs describe the focused loop as costing "generally less than
10%" CPU; the GPU cost is the shader's own per-pixel cost (see
`docs/PERFORMANCE.md`).

## 8. Errors

If a shader fails to compile, Ghostty **silently ignores it** and logs
`spirv error` / `shadertoy` messages; it is not reported as a config error.
`ghostfx validate` exists so you never have to discover this at runtime.

## 9. Resize, font size, HiDPI

`iResolution` follows the framebuffer in physical pixels, so HiDPI screens
report larger sizes. GhostFX normalises effect coordinates by the window
height (`gfx_p`) and scales pixel-sized features (scanlines, masks, halos) by
`gfx_dpi()` = height / 1440, so effects look the same across resolutions and
ultrawide windows simply reveal more horizontally. Ghostty does not expose the
cell size, so scanlines cannot lock to text rows.
