# Shader review checklist

**Correctness**
- [ ] `ghostfx validate` passes (Ghostty SPIR-V, GLSL 430, MSL, legacy 1.2, ES 3.00), no warnings
- [ ] Renders in Ghostty (`ghostfx preview <id> --window` or `generate-previews`)
- [ ] No `atan()` seams, no tiling seams, no NaNs (divisions guarded)
- [ ] Looks right at 16:9, 21:9 ultrawide and portrait-ish windows; scales with HiDPI

**Readability & accessibility**
- [ ] Glyphs untouched in background mode; `balanced` contrast estimate ≥ 4.5:1
- [ ] `subtle` preset is calm enough for all-day use
- [ ] Flashes routed through `gfx_flash()` and `@flashing true` set
- [ ] Text movement only via `gfx_text_offset()` / `GFX_DISTORT_TEXT`, `@distorts true` set
- [ ] `--reduced-motion` produces a calm result

**Performance**
- [ ] Loops bounded by constants or `GFX_*`/`P_*`, scale with `GFX_QUALITY`
- [ ] Texture taps per pixel justified (≤ ~12 except deliberate post filters)
- [ ] `ghostfx benchmark <id>` not dramatically slower than similar shaders

**Metadata & originality**
- [ ] id/name/description/tags/colours meaningful; parameters have ranges and descriptions
- [ ] Not a near-duplicate (`tests/test_duplicates.py`), clearly distinct technique or look
- [ ] Original work, or attribution and compatible licence recorded
