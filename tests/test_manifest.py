import json

from ghostfx.manifest import build_manifest, validate_manifest
from ghostfx.paths import data_root


def test_committed_manifest_is_valid_and_current():
    data = json.loads((data_root() / "manifest.json").read_text())
    assert validate_manifest(data) == []
    fresh = build_manifest()
    assert [s["id"] for s in data["shaders"]] == [s["id"] for s in fresh["shaders"]]


def test_dist_is_up_to_date():
    from ghostfx import build, meta

    for s in meta.load_all():
        built = (data_root() / "dist" / s.category / f"{s.id}.glsl").read_text()
        assert built == build.build_shader(s), f"dist/{s.category}/{s.id}.glsl is stale; run `ghostfx build --all`"
