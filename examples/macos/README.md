# GhostFX on macOS

```sh
pipx install "git+https://github.com/r3dg0d/ghostfx"      # or: nix profile install github:r3dg0d/ghostfx
brew install glslang spirv-cross                           # optional, enables `ghostfx validate`
ghostfx apply ender-portal
```

Notes:

* Ghostty on macOS defaults to `alpha-blending = native`; `ghostfx apply` reads
  your config and builds the shader for the matching colour space.
* Ghostty on macOS has no reload signal: press **cmd+shift+,** (Reload
  Configuration) after `ghostfx apply` / `ghostfx disable`.
* GhostFX edits `~/.config/ghostty/config(.ghostty)` if it exists, otherwise
  `~/Library/Application Support/com.mitchellh.ghostty/config(.ghostty)`.
* Metal compatibility is checked by cross-compiling every shader to MSL with
  SPIRV-Cross, exactly as Ghostty does, but GhostFX has not yet been run on
  a Mac by the maintainers. Reports are welcome.
