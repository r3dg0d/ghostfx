import pytest

from ghostfx import meta, presets
from ghostfx.meta import MetaError


def test_parse_preset_file():
    pf = presets.parse_preset("""
[shader]
name = "ender-portal"
base = "cinematic"
intensity = 0.5
quality = "eco"
reduced_motion = true
palette = "matrix-green"

[colors]
primary = "#112233"

[params]
depth = 1.4
""")
    assert pf.shader == "ender-portal" and pf.base == "cinematic" and pf.palette == "matrix-green"
    assert pf.overrides == {"INTENSITY": 0.5, "QUALITY": "eco", "REDUCED_MOTION": True, "PRIMARY": "#112233", "DEPTH": 1.4}


def test_bad_presets_are_rejected():
    with pytest.raises(MetaError):
        presets.parse_preset("[shader]\nintensity = 1\n")
    with pytest.raises(MetaError):
        presets.parse_preset('[shader]\nname = "fog"\nbogus = 1\n')
    with pytest.raises(MetaError):
        presets.parse_preset('[shader]\nname = "fog"\n[colors]\npink = "#fff000"\n')


def test_twelve_palettes():
    pals = presets.list_palettes()
    assert len(pals) >= 12
    for name in pals:
        assert set(presets.load_palette(name)) >= {"PRIMARY", "SECONDARY", "ACCENT"}


def test_generated_preset_files_exist_for_every_shader():
    from ghostfx.paths import data_root

    for s in meta.load_all():
        assert (data_root() / "presets" / s.category / f"{s.id}.toml").exists(), s.id
