"""Shader validation.

Reproduces Ghostty's own shader pipeline (src/renderer/shadertoy.zig):

  1. prepend Ghostty's shadertoy prefix (GLSL 430 core)
  2. glslang -> SPIR-V 1.5 for Vulkan 1.2
  3. SPIRV-Cross -> GLSL 430 (OpenGL renderer, Linux)
  4. SPIRV-Cross -> MSL (Metal renderer, macOS)

plus a GLSL ES 3.00 compile for the browser gallery and a legacy compile
against the Ghostty 1.2 prefix. Passing here means the shader is accepted by
the same compiler front end Ghostty uses; it does not prove it renders well.
"""

from __future__ import annotations

import re
import shutil
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

from .paths import data_root

TOOLS = ("glslangValidator", "spirv-cross")


@dataclass
class StageResult:
    stage: str
    ok: bool | None  # None = skipped
    log: str = ""


@dataclass
class Report:
    name: str
    stages: list[StageResult] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return not self.errors and all(s.ok is not False for s in self.stages)

    def to_json(self) -> dict:
        return {
            "name": self.name,
            "ok": self.ok,
            "errors": self.errors,
            "warnings": self.warnings,
            "stages": [{"stage": s.stage, "ok": s.ok, "log": s.log} for s in self.stages],
        }


def have_tools() -> dict[str, bool]:
    return {t: shutil.which(t) is not None for t in TOOLS}


def _prefix(name: str) -> str:
    return (data_root() / "compat" / name).read_text(encoding="utf-8")


def _run(cmd: list[str]) -> tuple[bool, str]:
    p = subprocess.run(cmd, capture_output=True, text=True)
    out = (p.stdout + p.stderr).strip()
    return p.returncode == 0, out


def static_checks(src: str, rep: Report) -> None:
    code = re.sub(r"//[^\n]*", "", src)
    code = re.sub(r"/\*.*?\*/", "", code, flags=re.S)
    if not re.search(r"\bvoid\s+mainImage\s*\(\s*out\s+vec4\s+\w+\s*,\s*in\s+vec2\s+\w+\s*\)", code):
        rep.errors.append("missing `void mainImage(out vec4 fragColor, in vec2 fragCoord)`")
    if re.search(r"\bvoid\s+main\s*\(", code):
        rep.errors.append("defines main(); Ghostty's prefix already provides it")
    if re.search(r"^\s*#\s*version", code, re.M):
        rep.errors.append("contains #version; Ghostty's prefix already sets it")
    if re.search(r"^\s*#\s*include", code, re.M):
        rep.errors.append("#include is not supported by Ghostty; build with ghostfx")
    for ch in ("iChannel1", "iChannel2", "iChannel3"):
        if ch in code:
            rep.errors.append(f"uses {ch}; Ghostty only binds iChannel0 (the terminal)")
    for u, why in (
        ("iMouse", "always zero in Ghostty"),
        ("iDate", "not updated by Ghostty"),
        ("iChannelTime", "not updated by Ghostty"),
        ("iSampleRate", "Ghostty has no audio input"),
    ):
        if re.search(rf"\b{u}\b", code):
            rep.warnings.append(f"uses {u}: {why}")
    reserved = re.findall(r"\b(?:float|int|vec[234]|bool)\s+(active|sample|filter|input|output|common|partition|patch|subroutine|noperspective|superp)\b", code)
    for w in sorted(set(reserved)):
        rep.errors.append(f"'{w}' is a reserved word in GLSL 4.30 / ES 3.00; rename the variable")
    if re.search(r"\biFrameRate\b", code):
        rep.warnings.append("uses iFrameRate: fixed at 60 in Ghostty")


def validate_source(src: str, name: str = "shader", webgl: bool = True, legacy_src: str | None = None) -> Report:
    rep = Report(name)
    static_checks(src, rep)
    tools = have_tools()
    if not all(tools.values()):
        missing = ", ".join(t for t, ok in tools.items() if not ok)
        rep.stages.append(StageResult("compile", None, f"skipped: missing {missing}"))
        return rep

    with tempfile.TemporaryDirectory(prefix="ghostfx-") as td:
        tdp = Path(td)
        full = tdp / "ghostty.frag"
        full.write_text(_prefix("ghostty-1.3-prefix.glsl") + "\n\n" + src)
        spv = tdp / "ghostty.spv"
        ok, log = _run(["glslangValidator", "-V", "--target-env", "vulkan1.2", "-S", "frag", "-o", str(spv), str(full)])
        rep.stages.append(StageResult("ghostty-spirv", ok, "" if ok else _clean(log, full)))
        if ok:
            gl = tdp / "opengl.frag"
            ok2, log2 = _run(["spirv-cross", "--version", "430", "--no-es", str(spv), "--output", str(gl)])
            if ok2:
                ok2, log2 = _run(["glslangValidator", "-S", "frag", str(gl)])
            rep.stages.append(StageResult("opengl-glsl430", ok2, "" if ok2 else log2))
            ok3, log3 = _run(["spirv-cross", "--msl", "--msl-decoration-binding", str(spv), "--output", str(tdp / "metal.metal")])
            rep.stages.append(StageResult("metal-msl", ok3, "" if ok3 else log3))
        if legacy_src is not None:
            lf = tdp / "legacy.frag"
            lf.write_text(_prefix("ghostty-1.2-prefix.glsl") + "\n\n" + legacy_src)
            okl, logl = _run(["glslangValidator", "-V", "--target-env", "vulkan1.2", "-S", "frag", "-o", str(tdp / "l.spv"), str(lf)])
            rep.stages.append(StageResult("ghostty-1.2-legacy", okl, "" if okl else _clean(logl, lf)))
        if webgl:
            wf = tdp / "webgl.frag"
            wf.write_text(_prefix("webgl-prefix.glsl") + "\n" + src)
            okw, logw = _run(["glslangValidator", "-S", "frag", str(wf)])
            rep.stages.append(StageResult("webgl-es300", okw, "" if okw else _clean(logw, wf)))
    return rep


def _clean(log: str, path: Path) -> str:
    keep = [l.replace(str(path), path.name) for l in log.splitlines() if "ERROR" in l or "error" in l.lower()]
    return "\n".join(keep[:12]) or log[:2000]


def validate_file(path: Path) -> Report:
    """Validate a raw Ghostty shader file or a GhostFX source shader."""
    text = path.read_text(encoding="utf-8")
    from .build import build_shader
    from .meta import parse_shader

    if re.search(r"^//\s*@id\b", text, re.M):
        sh = parse_shader(path)
        return validate_source(build_shader(sh), sh.id, legacy_src=build_shader(sh, legacy=True))
    return validate_source(text, path.name, webgl=False)
