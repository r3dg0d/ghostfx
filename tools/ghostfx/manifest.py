"""manifest.json generation and validation."""

from __future__ import annotations

import json
import re
from pathlib import Path

from . import __version__
from .meta import CATEGORIES, COMMON_PARAMS, Shader, load_all
from .paths import data_root

SCHEMA_VERSION = 1


def _load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


def capabilities(shader: Shader) -> list[str]:
    from .build import build_shader

    src = build_shader(shader)
    caps = ["terminal-texture"]
    if shader.animated:
        caps.append("animation")
    if "fwidth" in src:
        caps.append("derivatives")
    if "GFX_TIME_FOCUS" in shader.body or "GFX_FOCUSED" in shader.body:
        caps.append("focus-uniforms")
    if "iCurrentCursor" in shader.body:
        caps.append("cursor-uniforms")
    return caps


def entry(shader: Shader, verification: dict, benchmarks: dict, previews_root: Path, order: int = 0, bench_meta: dict | None = None) -> dict:
    bench_meta = bench_meta or {}
    v = verification.get(shader.id, {})
    b = benchmarks.get(shader.id)
    previews = {}
    for kind, rel in (
        ("thumbnail", f"thumbnails/{shader.id}.webp"),
        ("animated", f"previews/{shader.id}.webp"),
        ("screenshot", f"previews/{shader.id}.png"),
    ):
        if (previews_root / rel).exists():
            previews[kind] = rel
    # Common parameters are listed once at the top level ("common_parameters").
    params = [dict(p.to_json(), common=False) for p in shader.params.values()]
    linux_status = "verified" if v.get("ghostty_render") == "pass" else ("compiles" if v.get("compile") == "pass" else "unknown")
    macos_status = "compiles-msl" if v.get("msl") == "pass" else "unknown"
    return {
        "id": shader.id,
        "name": shader.name,
        "category": shader.category,
        "category_name": CATEGORIES[shader.category],
        "description": shader.description,
        "author": shader.author,
        "license": shader.license,
        "version": shader.version,
        "source": shader.rel_source(),
        "dist": f"dist/{shader.category}/{shader.id}.glsl",
        "mode": shader.mode,
        "animated": shader.animated,
        "flashing": shader.flashing,
        "distorts_text": shader.distorts_text,
        "reduced_motion": True,
        "presets": shader.presets,
        "preset_values": {p: shader.preset_values(p) for p in shader.presets},
        "added": shader.added,
        "order": order,
        "tags": shader.tags,
        "colors": shader.all_colors(),
        "parameters": params,
        "modules": shader.uses,
        "required_capabilities": capabilities(shader),
        "min_ghostty": "1.3.0",
        "legacy_build": "1.2.0",
        "known_limitations": shader.limitations,
        "attribution": shader.inspired_by or None,
        "platforms": {"linux": linux_status, "macos": macos_status},
        "verification": {
            "compile": v.get("compile", "unknown"),
            "ghostty_render": v.get("ghostty_render", "untested"),
            "animates": v.get("animates"),
            "readability_contrast": v.get("contrast"),
            "ghostty_version": v.get("ghostty_version"),
            "checked": v.get("date"),
        },
        "benchmark": (
            {"status": "measured", "renderer": bench_meta.get("renderer"), "note": bench_meta.get("note"),
             "results": {k: {"gpu_ms_median": r["gpu_ms_median"], "gpu_ms_p95": r["gpu_ms_p95"]} for k, r in b.items()}}
            if b else {"status": "not-benchmarked"}
        ),
        "previews": previews,
    }


def build_manifest(root: Path | None = None) -> dict:
    root = root or data_root()
    shaders = load_all(root)
    verification = _load_json(root / "tests" / "verification.json").get("shaders", {})
    bench_all = _load_json(root / "benchmarks" / "results.json")
    benchmarks = bench_all.get("shaders", {})
    bench_meta = {"renderer": bench_all.get("renderer"), "note": bench_all.get("note")}
    return {
        "$schema": "./docs/manifest.schema.json",
        "schema_version": SCHEMA_VERSION,
        "generator": f"ghostfx {__version__}",
        "project": "GhostFX",
        "repository": "https://github.com/r3dg0d/ghostfx",
        "license": "MIT",
        "shader_count": len(shaders),
        "common_parameters": [
            {"name": k, "type": t, "default": d, "min": lo, "max": hi, "description": desc, "common": True}
            for k, (t, d, lo, hi, desc) in COMMON_PARAMS.items()
        ],
        "categories": {k: {"name": v, "count": sum(1 for s in shaders if s.category == k)} for k, v in CATEGORIES.items() if any(s.category == k for s in shaders)},
        "shaders": [entry(s, verification, benchmarks, root, i, bench_meta) for i, s in enumerate(shaders)],
    }


REQUIRED = ["id", "name", "category", "description", "author", "license", "animated", "presets", "tags", "source", "version"]


def validate_manifest(data: dict) -> list[str]:
    """Structural checks mirrored by docs/manifest.schema.json (no external deps)."""
    errs = []
    if data.get("schema_version") != SCHEMA_VERSION:
        errs.append("schema_version mismatch")
    seen = set()
    for i, s in enumerate(data.get("shaders", [])):
        where = s.get("id", f"#{i}")
        for k in REQUIRED:
            if k not in s:
                errs.append(f"{where}: missing {k}")
        if not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", s.get("id", "")):
            errs.append(f"{where}: bad id")
        if s.get("id") in seen:
            errs.append(f"{where}: duplicate id")
        seen.add(s.get("id"))
        if s.get("category") not in CATEGORIES:
            errs.append(f"{where}: unknown category")
        if not s.get("presets"):
            errs.append(f"{where}: no presets")
        if len(s.get("description", "")) < 20:
            errs.append(f"{where}: description too short")
        if not s.get("tags"):
            errs.append(f"{where}: no tags")
    if data.get("shader_count") != len(data.get("shaders", [])):
        errs.append("shader_count does not match")
    return errs


def write_manifest(root: Path | None = None) -> Path:
    root = root or data_root()
    m = build_manifest(root)
    out = root / "manifest.json"
    out.write_text(json.dumps(m, indent=2) + "\n", encoding="utf-8")
    return out
