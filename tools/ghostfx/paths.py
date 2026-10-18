"""Filesystem locations: GhostFX data and Ghostty configuration."""

from __future__ import annotations

import os
import platform
from pathlib import Path


def data_root() -> Path:
    """Directory holding shaders/, glsl/, themes/ and compat/.

    Resolution order: $GHOSTFX_DATA, bundled package data, source checkout.
    """
    env = os.environ.get("GHOSTFX_DATA")
    if env:
        return Path(env)
    here = Path(__file__).resolve().parent
    for cand in (here / "data", here.parent.parent):
        if (cand / "shaders").is_dir() and (cand / "glsl").is_dir():
            return cand
    raise FileNotFoundError(
        "GhostFX data directory not found; set GHOSTFX_DATA to the repository root"
    )


def xdg_config_home() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")


def ghostty_config_candidates() -> list[Path]:
    """Config files Ghostty reads, in the order Ghostty loads them."""
    cands = [xdg_config_home() / "ghostty" / "config"]
    if platform.system() == "Darwin":
        cands.append(
            Path.home() / "Library" / "Application Support" / "com.mitchellh.ghostty" / "config"
        )
    return cands


def ghostty_config_path() -> Path:
    """The config file GhostFX edits: $GHOSTFX_GHOSTTY_CONFIG, else the first
    existing candidate, else the XDG path (created on demand)."""
    env = os.environ.get("GHOSTFX_GHOSTTY_CONFIG")
    if env:
        return Path(env)
    for c in ghostty_config_candidates():
        if c.exists():
            return c
    return ghostty_config_candidates()[0]


def ghostfx_home() -> Path:
    """User state: installed shaders, presets, favorites, backups."""
    env = os.environ.get("GHOSTFX_HOME")
    if env:
        return Path(env)
    return xdg_config_home() / "ghostty" / "ghostfx"


def installed_shader_dir() -> Path:
    return ghostfx_home() / "shaders"


def user_preset_dir() -> Path:
    return ghostfx_home() / "presets"


def backup_dir() -> Path:
    return ghostfx_home() / "backups"


def state_file() -> Path:
    return ghostfx_home() / "state.json"
