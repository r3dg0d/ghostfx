import re
from pathlib import Path

from ghostfx import meta
from ghostfx.build import modules

HERE = Path(__file__).parent


def catalog_ids():
    text = (HERE / "catalog.txt").read_text()
    return [w for line in text.splitlines() if not line.startswith("#") for w in line.split()]


def test_catalog_has_180_unique_ids():
    ids = catalog_ids()
    assert len(ids) == 180
    assert len(set(ids)) == 180


def test_every_catalog_shader_is_implemented():
    have = {s.id for s in meta.load_all()}
    missing = [i for i in catalog_ids() if i not in have]
    assert not missing, f"missing implementations: {missing}"


def test_at_least_180_shaders():
    assert len(meta.load_all()) >= 180


def test_metadata_quality():
    for s in meta.load_all():
        assert len(s.description) >= 40, s.id
        assert s.tags, s.id
        assert {"subtle", "balanced", "cinematic"} <= set(s.presets), s.id
        assert "mainImage" in s.body, s.id
        for u in s.uses:
            assert u in modules(), f"{s.id}: unknown module {u}"


def test_flashing_shaders_use_flash_limiter():
    # Anything declared as flashing must route flashes through gfx_flash()
    # or REDUCED_FLASH so `--reduced-flash` works.
    for s in meta.load_all():
        if s.flashing:
            assert "gfx_flash" in s.body or "GFX_REDUCED_FLASH" in s.body, s.id


def test_distorting_shaders_respect_distort_text():
    for s in meta.load_all():
        if s.distorts_text:
            assert re.search(r"gfx_text_offset|GFX_DISTORT_TEXT", s.body), s.id


def test_readme_states_the_real_shader_count():
    readme = (HERE.parent / "README.md").read_text()
    n = len(meta.load_all())
    assert f"{n} original" in readme and f"{n} distinct shaders" in readme
