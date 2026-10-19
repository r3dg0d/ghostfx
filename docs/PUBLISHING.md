# Publishing GhostFX to GitHub

The repository was prepared locally. Creating `r3dg0d/ghostfx` from the build session was
not possible: the GitHub integration returned `403 Resource not accessible by integration`.
To publish:

```sh
# 1. Create the public repository (GitHub CLI, authenticated as r3dg0d)
gh auth status
gh repo view r3dg0d/ghostfx >/dev/null 2>&1 && echo "exists: inspect before pushing!" || \
gh repo create r3dg0d/ghostfx --public \
  --description "GhostFX — 180+ open-source animated GLSL shaders for the Ghostty terminal. Ocean, fire, CRT, cyberpunk, space, portals, particles, glass, and more."

# 2. Topics
gh repo edit r3dg0d/ghostfx --add-topic ghostty,ghostty-shaders,glsl,shaders,terminal,linux,macos,nixos,hyprland,opengl,cyberpunk,visual-effects,open-source

# 3. Push (from the repository root; never force-push over existing history)
git remote add origin git@github.com:r3dg0d/ghostfx.git
git push -u origin main

# 4. Enable GitHub Pages (Settings → Pages → Source: GitHub Actions); the
#    "Gallery (GitHub Pages)" workflow deploys to https://r3dg0d.github.io/ghostfx/

# 5. Pre-release once CI is green (v1.0.0 waits for GPU benchmarks + macOS runs)
git tag v0.9.0 && git push origin v0.9.0
```

Before pushing, the release checklist: `pytest -q`, `ghostfx manifest --check`,
`nix flake check`, `cd website && npm ci && npm run build`. No secrets are committed
(the Security workflow greps for common token formats).
