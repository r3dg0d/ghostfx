# GLSL style guide

* 4-space indent, `lower_snake_case` functions, `UPPER_CASE` defines,
  `camelCase` or short math names (`p`, `uv`, `t`, `col`) for locals.
* Float literals always have a decimal point (`1.0`, not `1`).
* Write one short comment per non-obvious technique ("why", not "what").
* Shared helpers go in `glsl/<area>/<module>.glsl` with `// @module` and
  `// @requires` headers; prefix public helpers clearly (`gfx_`, `sd_`,
  `hash`, `fbm`...). Never duplicate a library function inside a shader.
* Prefer analytic effects over iteration; scale loop counts with
  `GFX_OCTAVES` / `GFX_STEPS` / `GFX_LAYERS`.
* One texture lookup through `gfx_term()` per pixel is the norm; extra taps
  (bloom, halos, chroma) should be justified and bounded.
* Never divide by a value that can reach zero: `max(x, 1e-4)`.
* Use `smoothstep` with `edge0 < edge1` when it matters for portability;
  reversed edges are relied upon only for simple fall-offs.
* Hash with the sine-free hashes in `glsl/common/hash.glsl` for results that
  match across GPUs.
