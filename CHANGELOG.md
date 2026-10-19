# Changelog

All notable changes are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.9.0] - 2026-10-18

First public pre-release.

### Added
- 253 shaders in 18 categories, including all 180 shaders of the v1 catalogue.
- GLSL library: Ghostty compatibility core (colour-space handling, text masking,
  readability, compositing modes), hashes, value/gradient/simplex noise, fBm, ridged
  noise, domain warping, Voronoi, SDFs, colour, lighting, CRT and particle helpers.
- `ghostfx` CLI: list/search/info/preview/install/apply/export/current/disable/uninstall,
  favorites, random, presets, palettes, config show/edit/validate, rollback, validate,
  benchmark, doctor, update, an interactive TUI, `--json` and `--dry-run`.
- Safe config management: managed block, atomic writes, backups, rollback, protection of
  foreign `custom-shader` lines, Home Manager detection, SIGUSR2 reload.
- Validation through Ghostty's real pipeline (glslang → SPIR-V → SPIRV-Cross GLSL 430 + MSL),
  legacy 1.2 builds, and GLSL ES 3.00.
- Real-Ghostty capture pipeline for previews and verification (animation, contrast).
- Offscreen renderer and GPU-timer benchmarks.
- Nix flake (package, prebuilt shaders, dev shell, checks), Home Manager module, examples.
- Next.js gallery with live WebGL2 previews and parameter controls.
- 12 palettes, generated presets for every shader, manifest.json with JSON schema.
- CI, release, Pages and security workflows.

### Known limitations
- macOS/Metal: MSL cross-compilation is verified, but nothing has run on real Mac hardware yet.
- Benchmarks so far only on software rendering (llvmpipe), not on real GPUs.
