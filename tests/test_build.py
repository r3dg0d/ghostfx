import re

import pytest

from ghostfx import build, meta
from ghostfx.meta import MetaError
from ghostfx.presets import load_palette


@pytest.mark.parametrize("shader", meta.load_all(), ids=lambda s: s.id)
def test_builds_for_every_preset_and_legacy(shader):
    for preset in shader.presets:
        src = build.build_shader(shader, preset)
        assert "#define GFX_INTENSITY" in src
        assert "void mainImage" in src
        assert "#include" not in src
        assert not re.search(r"^\s*#\s*version", src, re.M)
    assert "#define GFX_LEGACY 1" in build.build_shader(shader, legacy=True)


def test_overrides_palette_and_bounds():
    s = meta.find("ender-portal")
    src = build.build_shader(s, "subtle", {"INTENSITY": 0.42, "DEPTH": 1.5, "QUALITY": "ultra"}, load_palette("matrix-green"))
    assert "#define GFX_INTENSITY 0.42" in src
    assert "#define P_DEPTH 1.5" in src
    assert "#define GFX_QUALITY 2" in src
    assert "#define GFX_PRIMARY vec3(0.2314, 1.0000, 0.4196)" in src
    with pytest.raises(MetaError):
        build.build_shader(s, overrides={"INTENSITY": 7})
    with pytest.raises(MetaError):
        build.build_shader(s, overrides={"NOPE": 1})
    with pytest.raises(MetaError):
        build.build_shader(s, "no-such-preset")


def test_only_used_modules_are_inlined():
    src = build.build_shader(meta.find("classic-crt"))
    assert "float voronoi_edge" not in src
    assert "float scanline" in src
