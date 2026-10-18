# Accessibility and readability

GhostFX's first rule: **the terminal must stay usable.**

* **Text protection.** Background-mode shaders only paint where the terminal
  shows its background colour (detected against Ghostty's
  `iBackgroundColor`), so glyphs, prompts and coloured cells are untouched.
  `readability` (default 0.7) additionally caps effect luminance with a
  hue-preserving soft knee (light-on-dark themes) or lifts it (light themes),
  and at quality ≥ balanced darkens a small halo around glyphs.
* **Measured contrast.** `ghostfx generate-previews` renders each shader in
  real Ghostty and estimates text-vs-background contrast (WCAG-style ratio)
  using a no-shader capture to locate glyphs. Results are in
  `tests/verification.json` and on each gallery page. The estimate is
  unreliable for shaders that move text (CRT curvature, warps) because glyphs
  no longer line up with the reference.
* **Presets.** `subtle` (intensity 0.35, speed 0.6, max readability, no text
  distortion) is meant for all-day coding; `cinematic` is for screenshots.
* **Reduced motion.** `--reduced-motion` slows all animation to 20%.
  The gallery honours `prefers-reduced-motion` and shows a still frame.
* **Reduced flashing.** Shaders that flash are tagged `flashing` in the
  manifest and in the gallery. `--reduced-flash` routes every flash through
  `gfx_flash()` (20% amplitude) and slows strobing (e.g. interlace, arcs).
  Defaults avoid rapid full-screen luminance changes.
* **No text distortion.** `--no-distort` (`distort_text = 0`) guarantees
  text pixels are never moved, for every shader.
* **Brightness / saturation** are adjustable for every shader.
* **Colour-blind friendliness.** Effects never encode information in colour
  alone. The palettes `electric-blue`, `retro-amber` and `obsidian-black`
  avoid red/green contrast and suit deuteranopia/protanopia; any shader can be
  recoloured with `--palette` or `--set primary=#...`.
