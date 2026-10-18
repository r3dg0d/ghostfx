"""Offscreen renderer that mirrors Ghostty's OpenGL custom-shader pass.

The shader goes through the same conversion Ghostty performs (prefix ->
glslang SPIR-V -> SPIRV-Cross GLSL 430), is drawn as a full-screen triangle
with the `Globals` uniform block at binding 1 (std140, same layout as
`shadertoy.Uniforms` in Ghostty) and the terminal frame bound to iChannel0.

Used for fast previews and `ghostfx benchmark`. Final verification should
still go through a real Ghostty instance (scripts/ghostty-capture.sh).

Needs: moderngl, numpy, Pillow, glslangValidator, spirv-cross, and an
OpenGL 4.3 context (a GPU driver, or Mesa llvmpipe under Xvfb).
"""

from __future__ import annotations

import os
import struct
import subprocess
import tempfile
import time
from pathlib import Path

from .paths import data_root

UBO_SIZE = 4496

# xterm-ish default 16 colours; 16..255 follow the standard cube/ramp.
_ANSI = [
    "1d1f21", "cc6666", "b5bd68", "f0c674", "81a2be", "b294bb", "8abeb7", "c5c8c6",
    "666666", "d54e53", "b9ca4a", "e7c547", "7aa6da", "c397d8", "70c0b1", "eaeaea",
]


def default_palette() -> list[tuple[float, float, float]]:
    pal = [tuple(int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)) for h in _ANSI]
    steps = [0, 95, 135, 175, 215, 255]
    for r in steps:
        for g in steps:
            for b in steps:
                pal.append((r / 255, g / 255, b / 255))
    for i in range(24):
        v = (8 + 10 * i) / 255
        pal.append((v, v, v))
    return pal  # type: ignore[return-value]


def pack_uniforms(
    width: int,
    height: int,
    t: float,
    frame: int,
    bg=(0x28 / 255, 0x2C / 255, 0x34 / 255),
    fg=(1.0, 1.0, 1.0),
    cursor=(0.0, 0.0, 0.0, 0.0),
    focus: int = 1,
) -> bytes:
    b = bytearray(UBO_SIZE)
    struct.pack_into("3f", b, 0, width, height, 1.0)
    struct.pack_into("3f", b, 12, t, 1 / 60, 60.0)
    struct.pack_into("i", b, 24, frame)
    for i in range(4):
        struct.pack_into("3f", b, 96 + 16 * i, width, height, 1.0)
    struct.pack_into("4f", b, 208, *cursor)
    struct.pack_into("4f", b, 224, *cursor)
    struct.pack_into("4f", b, 240, *fg, 1.0)
    struct.pack_into("4f", b, 256, *fg, 1.0)
    struct.pack_into("3i", b, 272, 0, 0, 1)
    struct.pack_into("f", b, 284, 0.0)
    struct.pack_into("f", b, 288, 0.0)
    struct.pack_into("i", b, 292, focus)
    for i, c in enumerate(default_palette()):
        struct.pack_into("3f", b, 304 + 16 * i, *c)
    struct.pack_into("3f", b, 4400, *bg)
    struct.pack_into("3f", b, 4416, *fg)
    struct.pack_into("3f", b, 4432, *fg)
    struct.pack_into("3f", b, 4448, *bg)
    struct.pack_into("3f", b, 4464, *bg)
    struct.pack_into("3f", b, 4480, *fg)
    return bytes(b)


def ghostty_glsl(src: str) -> str:
    """Convert a Ghostty shader to the GLSL 430 Ghostty's OpenGL backend runs."""
    prefix = (data_root() / "compat" / "ghostty-1.3-prefix.glsl").read_text()
    with tempfile.TemporaryDirectory(prefix="ghostfx-r-") as td:
        f = Path(td) / "s.frag"
        f.write_text(prefix + "\n\n" + src)
        spv = Path(td) / "s.spv"
        out = Path(td) / "s.glsl"
        for cmd in (
            ["glslangValidator", "-V", "--target-env", "vulkan1.2", "-S", "frag", "-o", str(spv), str(f)],
            ["spirv-cross", "--version", "430", "--no-es", str(spv), "--output", str(out)],
        ):
            p = subprocess.run(cmd, capture_output=True, text=True)
            if p.returncode:
                raise RuntimeError(f"{cmd[0]} failed:\n{p.stdout}{p.stderr}")
        return out.read_text()


VERT = """#version 430 core
void main() {
    vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}
"""


def _ctx():
    import moderngl

    kw = {}
    if os.environ.get("GHOSTFX_LIBGL"):
        kw["libgl"] = os.environ["GHOSTFX_LIBGL"]
    return moderngl.create_standalone_context(require=430, **kw)


class Renderer:
    """Render one shader at a fixed size. `linear` mirrors alpha-blending
    linear/linear-corrected (texture holds linear colour, output is
    sRGB-encoded); otherwise native (display-encoded throughout)."""

    def __init__(self, src: str, width: int, height: int, terminal_png: Path | None = None, linear: bool = True):
        import numpy as np
        from PIL import Image

        self.np = np
        self.w, self.h, self.linear = width, height, linear
        self.ctx = _ctx()
        frag = ghostty_glsl(src)
        self.prog = self.ctx.program(vertex_shader=VERT, fragment_shader=frag)
        self.vao = self.ctx.vertex_array(self.prog, [])
        self.ubo = self.ctx.buffer(reserve=UBO_SIZE)

        term = Image.open(terminal_png or default_terminal()).convert("RGBA").resize((width, height))
        arr = np.asarray(term, dtype=np.float32) / 255.0
        arr = arr[::-1].copy()  # GL rows start at the bottom
        if linear:
            arr[..., :3] = srgb_to_linear(arr[..., :3])
        self.tex = self.ctx.texture((width, height), 4, arr.tobytes(), dtype="f4")
        self.tex.filter = (self.ctx.LINEAR, self.ctx.LINEAR)
        self.tex.repeat_x = self.tex.repeat_y = False
        self.fbo = self.ctx.simple_framebuffer((width, height), components=4, dtype="f4")

    def draw(self, t: float, frame: int = 0) -> None:
        self.ubo.write(pack_uniforms(self.w, self.h, t, frame))
        self.ubo.bind_to_uniform_block(1)
        self.tex.use(0)
        self.fbo.use()
        self.fbo.clear(0, 0, 0, 0)
        self.vao.render(mode=self.ctx.TRIANGLES, vertices=3)

    def image(self, t: float):
        from PIL import Image

        np = self.np
        self.draw(t)
        data = np.frombuffer(self.fbo.read(components=4, dtype="f4"), dtype=np.float32)
        data = data.reshape(self.h, self.w, 4)[::-1]
        rgb = np.clip(data[..., :3], 0, 1)
        if self.linear:
            rgb = linear_to_srgb(rgb)
        return Image.fromarray((rgb * 255 + 0.5).astype("uint8"), "RGB")

    def benchmark(self, frames: int = 60, warmup: int = 5) -> dict:
        """GPU time per frame via GL timer queries (falls back to wall clock)."""
        for i in range(warmup):
            self.draw(i / 60)
        self.ctx.finish()
        gpu: list[float] = []
        wall0 = time.perf_counter()
        for i in range(frames):
            q = self.ctx.query(time=True)
            with q:
                self.draw(1.0 + i / 60, i)
            gpu.append(q.elapsed / 1e6)
        self.ctx.finish()
        wall = (time.perf_counter() - wall0) * 1000 / frames
        gpu.sort()
        return {
            "width": self.w,
            "height": self.h,
            "frames": frames,
            "gpu_ms_median": round(gpu[len(gpu) // 2], 4),
            "gpu_ms_p95": round(gpu[int(len(gpu) * 0.95) - 1], 4),
            "wall_ms_mean": round(wall, 4),
            "renderer": self.ctx.info.get("GL_RENDERER", "?"),
        }

    def release(self) -> None:
        self.ctx.release()


def srgb_to_linear(c):
    import numpy as np

    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def linear_to_srgb(c):
    import numpy as np

    return np.where(c <= 0.0031308, c * 12.92, 1.055 * np.power(c, 1 / 2.4) - 0.055)


def default_terminal() -> Path:
    return data_root() / "tests" / "fixtures" / "terminal-1280x720.png"
