# Contributing to GhostFX

Thanks for helping make terminals more alive. Contributions of shaders, tooling, docs and
benchmarks are all welcome.

## Ground rules

* **Original work only.** Do not submit shaders copied from Shadertoy or elsewhere unless
  the licence is MIT-compatible and you add attribution to `THIRD_PARTY_NOTICES.md`.
  "Inspired by" a game or film is fine. Copying its assets or code is not.
* **Readability first.** Default presets must keep text readable (see
  `docs/ACCESSIBILITY.md`). Effects that flash must use `gfx_flash()`, and effects that
  move text must use `gfx_text_offset()`.
* **No duplicates.** A recolour or a renamed copy isn't a new shader. `tests/test_duplicates.py`
  enforces this.

## Developing a shader

1. Set up: `nix develop`, or `pip install -e ".[dev,preview]"` plus `glslang` and
   `spirv-cross` from your package manager.
2. Create `shaders/<category>/<id>.glsl` (see `docs/SHADER_FORMAT.md` for the header and
   helpers). Start from a similar existing shader.
3. Iterate:
   ```sh
   python3 -m ghostfx validate shaders/<category>/<id>.glsl   # Ghostty's compile chain
   python3 -m ghostfx preview <id> --out /tmp/p.png --time 6   # offscreen render
   python3 -m ghostfx preview <id> --window                    # real Ghostty window
   ```
4. Check all three presets (`--preset subtle|balanced|cinematic`) and `--reduced-motion`.
5. Regenerate generated files and run the tests:
   ```sh
   python3 -m ghostfx build --all --preset-files --manifest
   python3 -m ghostfx generate-previews <id>        # needs Ghostty + Xvfb or a display
   pytest -q
   ```
6. Open a pull request using the template. Attach a screenshot or short clip of the shader
   running in Ghostty.

## Review checklist

See `docs/REVIEW_CHECKLIST.md`. Reviewers check correctness on Ghostty's pipeline,
readability, performance (loop bounds, texture taps), accessibility flags, metadata
quality and originality.

## Code style

* Python: `ruff check tools tests`. Stdlib only at runtime, type hints, small functions.
* GLSL: `docs/GLSL_STYLE.md`.
* Commits: imperative mood ("Add aurora shader"), one logical change per commit.

## Reporting bugs

Use the bug report template and include `ghostfx doctor --json`, your Ghostty version
(`ghostty +version`), OS/GPU, and the relevant Ghostty log lines (`shadertoy`, `spirv`).
