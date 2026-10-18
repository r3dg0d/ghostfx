"""Assemble standalone Ghostty shaders.

Ghostty loads a single GLSL file per `custom-shader` entry and has no
#include support, so the build inlines the GhostFX library modules a shader
uses and prepends its parameters as #defines.
"""

from __future__ import annotations

import re
from functools import lru_cache
from pathlib import Path

from . import __version__
from .meta import COMMON_COLORS, COMMON_PARAMS, PROFILES, MetaError, Shader
from .paths import data_root

_MOD_RE = re.compile(r"^//\s*@module\s+(\S+)", re.M)
_REQ_RE = re.compile(r"^//\s*@requires\s+(.+)$", re.M)


class Module:
    def __init__(self, name: str, path: Path, requires: list[str], code: str):
        self.name, self.path, self.requires, self.code = name, path, requires, code


@lru_cache(maxsize=None)
def _modules(root: str) -> dict[str, Module]:
    mods: dict[str, Module] = {}
    for p in sorted((Path(root) / "glsl").rglob("*.glsl")):
        text = p.read_text(encoding="utf-8")
        m = _MOD_RE.search(text)
        if not m:
            continue
        reqs: list[str] = []
        for r in _REQ_RE.findall(text):
            reqs.extend(r.split())
        mods[m.group(1)] = Module(m.group(1), p, reqs, text)
    return mods


def modules() -> dict[str, Module]:
    return _modules(str(data_root()))


def resolve_modules(uses: list[str]) -> list[Module]:
    mods = modules()
    order: list[Module] = []
    state: dict[str, int] = {}

    def visit(name: str, chain: tuple[str, ...]) -> None:
        if name not in mods:
            raise MetaError(f"unknown GLSL module '{name}' (needed by {' -> '.join(chain) or 'shader'})")
        if state.get(name) == 2:
            return
        if state.get(name) == 1:
            raise MetaError(f"module cycle: {' -> '.join(chain + (name,))}")
        state[name] = 1
        for r in mods[name].requires:
            visit(r, chain + (name,))
        state[name] = 2
        order.append(mods[name])

    visit("core", ())
    for u in uses:
        visit(u, ())
    return order


def hex_to_vec3(h: str) -> str:
    h = h.lstrip("#")
    r, g, b = (int(h[i : i + 2], 16) / 255.0 for i in (0, 2, 4))
    return f"vec3({r:.4f}, {g:.4f}, {b:.4f})"


def _fmt(typ: str, v: float) -> str:
    if typ == "int":
        return str(int(round(v)))
    f = float(v)
    s = f"{f:.6f}".rstrip("0")
    return s + "0" if s.endswith(".") else s


def resolve_values(
    shader: Shader,
    preset: str = "balanced",
    overrides: dict | None = None,
    palette: dict[str, str] | None = None,
) -> tuple[dict[str, tuple[str, float]], dict[str, str]]:
    """Return ({NAME: (type, value)}, {COLOR: hex}) after applying layers:
    common defaults < shader params < preset < palette < overrides."""
    vals: dict[str, tuple[str, float]] = {k: (t, d) for k, (t, d, *_r) in COMMON_PARAMS.items()}
    for p in shader.params.values():
        vals[p.name] = (p.type, p.default)
    colors = shader.all_colors()

    def apply(layer: dict, where: str) -> None:
        for k, v in layer.items():
            k = k.upper()
            if k in COMMON_COLORS or (isinstance(v, str) and v.startswith("#")):
                if k not in COMMON_COLORS:
                    raise MetaError(f"{where}: unknown color '{k}'")
                colors[k] = str(v).upper()
                continue
            if k == "QUALITY" and isinstance(v, str):
                if v not in PROFILES:
                    raise MetaError(f"{where}: quality must be one of {', '.join(PROFILES)}")
                v = PROFILES[v]
            if k not in vals:
                raise MetaError(f"{where}: '{shader.id}' has no parameter '{k}'")
            typ = vals[k][0]
            if isinstance(v, bool):
                v = int(v)
            lo, hi = _bounds(shader, k)
            if not (lo <= float(v) <= hi):
                raise MetaError(f"{where}: {k}={v} outside [{lo}, {hi}]")
            vals[k] = (typ, v)

    apply(shader.preset_values(preset), f"preset {preset}")
    if palette:
        apply(palette, "palette")
    if overrides:
        apply(overrides, "overrides")
    return vals, colors


def _bounds(shader: Shader, k: str) -> tuple[float, float]:
    if k in COMMON_PARAMS:
        _t, _d, lo, hi, _desc = COMMON_PARAMS[k]
        return lo, hi
    p = shader.params[k]
    return p.min, p.max


def build_shader(
    shader: Shader,
    preset: str = "balanced",
    overrides: dict | None = None,
    palette: dict[str, str] | None = None,
    legacy: bool = False,
) -> str:
    vals, colors = resolve_values(shader, preset, overrides, palette)
    mods = resolve_modules(shader.uses)

    out: list[str] = [
        f"// GhostFX — {shader.name} ({shader.id}) v{shader.version}",
        f"// {shader.description}",
        f"// Category: {shader.category} | Mode: {shader.mode} | Preset: {preset}",
        f"// Source: {shader.rel_source()} | Built by ghostfx {__version__}",
        f"// License: {shader.license} | https://github.com/r3dg0d/ghostfx",
        "// Generated file: edit the source and rebuild instead.",
        "// Requires Ghostty >= 1.3" if not legacy else "// Legacy build for Ghostty 1.1/1.2",
        "",
    ]
    if legacy:
        out.append("#define GFX_LEGACY 1")
    for k, (typ, v) in vals.items():
        # bools are emitted as floats so comparisons stay valid in GLSL ES.
        emit_t = "int" if typ == "int" else "float"
        prefix = "GFX_" if k in COMMON_PARAMS else "P_"
        out.append(f"#define {prefix}{k} {_fmt(emit_t, v)}")
    for k in COMMON_COLORS:
        out.append(f"#define GFX_{k} {hex_to_vec3(colors[k])}")
    out.append("")
    for m in mods:
        out.append(_strip_header(m.code).rstrip())
        out.append("")
    out.append(f"// ---- {shader.id} ----")
    out.append(shader.body.rstrip())
    out.append("")
    return "\n".join(out)


def _strip_header(code: str) -> str:
    lines = code.splitlines()
    return "\n".join(l for l in lines if not re.match(r"^//\s*@(module|requires)\b", l))
