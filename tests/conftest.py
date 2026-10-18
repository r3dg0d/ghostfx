import os
import shutil
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
os.environ.setdefault("GHOSTFX_DATA", str(ROOT))


@pytest.fixture
def sandbox(tmp_path, monkeypatch):
    """Isolated GhostFX state and Ghostty config."""
    home = tmp_path / "gfx"
    cfg = tmp_path / "ghostty" / "config"
    cfg.parent.mkdir(parents=True)
    monkeypatch.setenv("GHOSTFX_HOME", str(home))
    monkeypatch.setenv("GHOSTFX_GHOSTTY_CONFIG", str(cfg))
    return home, cfg


needs_glslang = pytest.mark.skipif(
    not (shutil.which("glslangValidator") and shutil.which("spirv-cross")),
    reason="glslangValidator/spirv-cross not installed",
)
