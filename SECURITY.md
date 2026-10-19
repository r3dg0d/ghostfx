# Security policy

## Supported versions

Only the latest release receives fixes.

## Scope

GhostFX modifies your Ghostty configuration and writes files under
`~/.config/ghostty/ghostfx/`. Relevant issues include anything that could:

* write outside those locations, or delete user files,
* corrupt a Ghostty configuration without a backup,
* execute commands from shader metadata, presets or palettes. They are data and are
  never evaluated, and preset TOML is parsed with `tomllib`.

Shaders run on your GPU inside Ghostty's sandboxed shader stage. A shader can't read
files or the network, but a pathological one could stall the GPU. Please report
shaders that hang drivers.

## Reporting

Please use **GitHub's private vulnerability reporting** ("Report a vulnerability" on the
Security tab) instead of a public issue. You should get a response within a week.
