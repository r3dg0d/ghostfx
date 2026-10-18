import pytest

from conftest import needs_glslang
from ghostfx import build, meta
from ghostfx.validate import static_checks, validate_source, Report


@needs_glslang
@pytest.mark.parametrize("shader", meta.load_all(), ids=lambda s: s.id)
def test_compiles_through_ghostty_pipeline(shader):
    """prefix -> glslang SPIR-V (Vulkan 1.2) -> SPIRV-Cross GLSL 430 + MSL,
    the legacy 1.2 prefix, and GLSL ES 3.00 for the browser gallery."""
    rep = validate_source(build.build_shader(shader), shader.id, legacy_src=build.build_shader(shader, legacy=True))
    assert rep.ok, rep.to_json()
    assert not rep.warnings, rep.warnings


def test_static_checks_catch_common_mistakes():
    rep = Report("x")
    static_checks("#version 330\nvoid main(){ texture(iChannel1, vec2(0)); iMouse; }", rep)
    msgs = " ".join(rep.errors + rep.warnings)
    assert "mainImage" in msgs and "#version" in msgs and "iChannel1" in msgs and "iMouse" in msgs


@needs_glslang
def test_broken_shader_is_rejected():
    rep = validate_source("void mainImage(out vec4 c, in vec2 f) { c = vec4(undefined_thing); }", "broken")
    assert not rep.ok
