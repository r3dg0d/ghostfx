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
    zipped = _extract_from_zipapp(here)
    if zipped:
        return zipped
    raise FileNotFoundError(
        "GhostFX data directory not found; set GHOSTFX_DATA to the repository root"
    )


def xdg_config_home() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")


def ghostty_config_candidates() -> list[Path]:
    """Config files Ghostty reads. Ghostty >= 1.2 prefers `config.ghostty`
    and still loads the legacy `config`; on macOS the Application Support
    directory is read as well."""
    x = xdg_config_home() / "ghostty"
    cands = [x / "config.ghostty", x / "config"]
    if platform.system() == "Darwin":
        app = Path.home() / "Library" / "Application Support" / "com.mitchellh.ghostty"
        cands += [app / "config.ghostty", app / "config"]
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
    # Nothing exists yet: the legacy name is read by every Ghostty release.
    return xdg_config_home() / "ghostty" / "config"


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


def _extract_from_zipapp(here: Path) -> Path | None:
    """Running from ghostfx.pyz: unpack the bundled data once into a cache."""
    import zipfile

    from . import __version__

    archive = next((p for p in here.parents if p.is_file() and zipfile.is_zipfile(p)), None)
    if archive is None:
        return None
    cache = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "ghostfx" / f"data-{__version__}"
    if not (cache / "shaders").is_dir():
        with zipfile.ZipFile(archive) as z:
            for name in z.namelist():
                if name.startswith("ghostfx/data/") and not name.endswith("/"):
                    dest = cache / name[len("ghostfx/data/"):]
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_bytes(z.read(name))
        script = cache / "scripts" / "ghostty-capture.sh"
        if script.exists():
            script.chmod(0o755)
    return cache
