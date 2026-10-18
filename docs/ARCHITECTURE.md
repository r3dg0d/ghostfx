# Architecture

```
shaders/<category>/<id>.glsl   source of truth: metadata header + mainImage
glsl/**                        reusable modules (core compat layer, noise, sdf, colour, crt...)
tools/ghostfx/                 Python package (stdlib only at runtime)
  meta.py       parse headers -> Shader objects, categories, common params, presets
  build.py      resolve modules, inject #defines, emit standalone Ghostty shaders
  presets.py    palettes (themes/*.toml) and user preset TOML files
  validate.py   Ghostty's compile chain: glslang SPIR-V -> SPIRV-Cross GLSL 430 + MSL,
                legacy 1.2 prefix, GLSL ES 3.00 (gallery)
  ghostty.py    config editing: managed block, backups, atomic writes, rollback, HM detection
  render.py     offscreen OpenGL renderer mirroring Ghostty's pass (previews, benchmarks)
  previews.py   real-Ghostty capture pipeline + verification records
  manifest.py   manifest.json
  cli.py, tui.py
compat/                        Ghostty's prefixes (1.2, 1.3) and the WebGL prefix
dist/                          pre-built balanced shaders (generated, checked in)
presets/                       generated preset documentation per shader
themes/                        12 palettes
nix/                           package, prebuilt-shader derivation, Home Manager module
website/                       Next.js static gallery (WebGL2 live previews)
tests/                         pytest suite, catalogue, Ghostty capture fixture, verification.json
benchmarks/                    benchmark results and how they were produced
```

Build flow: `source header` → `meta.Shader` → `build.build_shader(preset,
overrides, palette, legacy)` → standalone GLSL → (`validate`) → written to
`~/.config/ghostty/ghostfx/shaders/<id>.glsl` → managed `custom-shader` line
in the Ghostty config → SIGUSR2 reload.

The core module (`glsl/common/core.glsl`) is the compatibility layer between
GhostFX conventions and Ghostty's real interface: time scaling, coordinate
systems, colour-space conversion, terminal sampling, text masking and the
compositing modes described in `SHADER_FORMAT.md`.
