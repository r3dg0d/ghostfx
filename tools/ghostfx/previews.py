"""Preview generation and real-Ghostty verification.

Backend "ghostty" launches the real Ghostty binary (under Xvfb when there is
no display) via scripts/ghostty-capture.sh, so every preview is produced by
Ghostty's own shader pipeline. It records, per shader:

  * whether Ghostty loaded the shader without errors,
  * whether two frames 3 s apart differ (animation),
  * a text-contrast estimate against a no-shader baseline capture.

Results go to tests/verification.json; images to thumbnails/ and previews/.
"""

from __future__ import annotations

import datetime as _dt
import json
import os
import shutil
import subprocess
import tempfile
import queue
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from . import build, meta
from .paths import data_root


def _lum(img):
    import numpy as np

    a = np.asarray(img.convert("RGB"), dtype=np.float32) / 255.0
    lin = np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
    return lin @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)


def contrast_metric(shot, baseline) -> float:
    """WCAG-style contrast between glyph cores and the bright end of the
    surrounding background, using a no-shader capture to locate glyphs."""
    import numpy as np

    base = _lum(baseline)
    cur = _lum(shot)
    bg = float(np.median(base))
    glyph = base > bg + 0.25                 # bright glyph cores in the baseline
    near = np.zeros_like(glyph)
    rows = np.where(glyph.any(axis=1))[0]
    if len(rows) == 0:
        return 0.0
    near[rows.min(): rows.max() + 1, :] = True
    backg = near & ~glyph & (np.abs(base - bg) < 0.01)
    if glyph.sum() < 50 or backg.sum() < 50:
        return 0.0
    t = float(np.median(cur[glyph]))
    b = float(np.percentile(cur[backg], 90))
    hi, lo = max(t, b), min(t, b)
    return round((hi + 0.05) / (lo + 0.05), 2)


def _capture(src: str, out_prefix: Path, frames: int, interval: float, display: str, record: float | None = None) -> tuple[bool, str]:
    root = data_root()
    with tempfile.NamedTemporaryFile("w", suffix=".glsl", delete=False) as f:
        f.write(src)
        path = f.name
    env = dict(os.environ, GFX_CAPTURE_DISPNUM=display)
    if record:
        env["GFX_CAPTURE_RECORD"] = str(record)
    try:
        p = subprocess.run(
            [str(root / "scripts" / "ghostty-capture.sh"), path, str(out_prefix), str(frames), str(interval)],
            capture_output=True, text=True, env=env, timeout=120,
        )
        return p.returncode == 0, (p.stdout + p.stderr)[-2000:]
    except subprocess.TimeoutExpired:
        return False, "timeout"
    finally:
        os.unlink(path)


def _ghostty_version() -> str:
    exe = os.environ.get("GHOSTTY") or shutil.which("ghostty") or "ghostty"
    try:
        out = subprocess.run([exe, "+version"], capture_output=True, text=True, timeout=20).stdout
        for line in out.splitlines():
            if line.strip().lower().startswith("ghostty"):
                return line.split()[-1]
        return out.strip().splitlines()[0] if out.strip() else "unknown"
    except (OSError, subprocess.TimeoutExpired):
        return "unknown"


def generate(args) -> int:
    from PIL import Image, ImageChops

    root = data_root()
    shaders = meta.load_all() if args.all or not args.ids else [meta.find(i) for i in args.ids]
    thumbs = root / "thumbnails"
    prev = root / "previews"
    thumbs.mkdir(exist_ok=True)
    prev.mkdir(exist_ok=True)
    vpath = root / "tests" / "verification.json"
    ver = json.loads(vpath.read_text()) if vpath.exists() else {"shaders": {}}
    gver = _ghostty_version() if args.backend == "ghostty" else None
    baseline = Image.open(root / "tests" / "fixtures" / "terminal-1280x720.png")
    work = Path(tempfile.mkdtemp(prefix="ghostfx-prev-"))
    today = _dt.date.today().isoformat()

    # Each worker owns one X display number for the whole run.
    displays: queue.Queue = queue.Queue()
    for n in range(max(args.jobs, 1)):
        displays.put(f":{150 + n}")

    def capture_retry(src, prefix, frames, interval, disp, record=None):
        for _attempt in range(3):
            ok, log = _capture(src, prefix, frames, interval, disp, record)
            if ok or not any(m in log for m in ("open display", "Cannot open display", "timeout")):
                return ok, log
        return ok, log

    def one(i_s):
        i, s = i_s
        disp = displays.get()
        try:
            return one_on(s, disp)
        finally:
            displays.put(disp)

    def one_on(s, disp):
        src = build.build_shader(s)
        rec = {"compile": "pass", "date": today, "renderer": args.backend}
        if args.backend == "ghostty":
            ok, log = capture_retry(src, work / s.id, 2, 3.0, disp)
            rec["ghostty_version"] = gver
            if not ok:
                rec["ghostty_render"] = "fail"
                rec["log"] = log
                return s.id, rec
            a = Image.open(work / f"{s.id}-0.png").convert("RGB")
            b = Image.open(work / f"{s.id}-1.png").convert("RGB")
            if args.animated:
                capture_retry(src, work / f"{s.id}-anim", 1, 1, disp, record=3.0)
        else:
            from .render import Renderer

            r = Renderer(src, 1280, 720)
            a, b = r.image(6.0), r.image(7.5)
            r.release()
        diff = ImageChops.difference(a, b).convert("L")
        changed = sum(diff.point(lambda v: 255 if v > 4 else 0).histogram()[255:]) / (a.width * a.height)
        rec["animates"] = bool(changed > 0.001) if s.animated else None
        base_diff = ImageChops.difference(a, baseline.convert("RGB")).convert("L")
        rec["visible"] = sum(base_diff.point(lambda v: 255 if v > 4 else 0).histogram()[255:]) / (a.width * a.height) > 0.01
        rec["contrast"] = contrast_metric(a, baseline)
        rec["ghostty_render"] = "pass" if args.backend == "ghostty" and rec["visible"] else ("fail" if args.backend == "ghostty" else "n/a")
        if getattr(args, "full", False):
            a.save(prev / f"{s.id}.png", optimize=True)
        a.resize((640, 360), Image.LANCZOS).save(thumbs / f"{s.id}.webp", quality=82, method=6)
        anim = work / f"{s.id}-anim.mp4"
        if anim.exists():
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(anim), "-vf", "fps=12,scale=480:-1:flags=lanczos",
                            "-loop", "0", "-quality", "70", "-compression_level", "6", str(prev / f"{s.id}.webp")])
        return s.id, rec

    with ThreadPoolExecutor(max_workers=max(args.jobs, 1)) as ex:
        for sid, rec in ex.map(one, list(enumerate(shaders))):
            ver["shaders"][sid] = rec
            mark = "ok " if rec.get("ghostty_render") in ("pass", "n/a") else "FAIL"
            print(f"{mark} {sid:<26} animates={rec.get('animates')} contrast={rec.get('contrast')}", flush=True)
            vpath.write_text(json.dumps(ver, indent=2, sort_keys=True) + "\n")
    shutil.rmtree(work, ignore_errors=True)
    ver["ghostty_version"] = gver
    ver["environment"] = "Xvfb + Mesa llvmpipe (software OpenGL 4.6)" if args.backend == "ghostty" else "offscreen"
    vpath.write_text(json.dumps(ver, indent=2, sort_keys=True) + "\n")
    bad = [k for k, v in ver["shaders"].items() if v.get("ghostty_render") == "fail"]
    return 1 if bad else 0
