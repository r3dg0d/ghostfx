"""Per-user GhostFX state: installed builds, favorites, current shader."""

from __future__ import annotations

import json
from pathlib import Path

from .paths import state_file

DEFAULT = {"installed": {}, "favorites": [], "current": None}


def load() -> dict:
    p = state_file()
    if not p.exists():
        return json.loads(json.dumps(DEFAULT))
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return json.loads(json.dumps(DEFAULT))
    for k, v in DEFAULT.items():
        data.setdefault(k, json.loads(json.dumps(v)))
    return data


def save(data: dict) -> None:
    from .ghostty import atomic_write

    p: Path = state_file()
    atomic_write(p, json.dumps(data, indent=2, sort_keys=True) + "\n")
