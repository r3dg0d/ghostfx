#!/usr/bin/env bash
# Reproducible benchmark run. Measures GPU time per frame with GL timer
# queries through the same GLSL 4.30 that Ghostty's OpenGL renderer executes
# (prefix -> glslang SPIR-V -> SPIRV-Cross). Needs an OpenGL 4.3 context:
# a real GPU driver, or Mesa llvmpipe under Xvfb (software: CPU-bound numbers).
#
#   benchmarks/run.sh [ids...]          # default: representative set below
#   GHOSTFX_BENCH_ALL=1 benchmarks/run.sh
set -euo pipefail
cd "$(dirname "$0")/.."
ids=("$@")
if [[ ${#ids[@]} -eq 0 && -z "${GHOSTFX_BENCH_ALL:-}" ]]; then
  ids=(classic-crt fog liquid-gradient ender-portal matrix-rain starfield ocean-waves realistic-fire
       nebula black-hole liquid-glass lightning liquid-metal northern-lights digital-glitch
       alien-interface fractal-zoom underwater-caustics hexagonal-grid reality-break)
fi
args=(--sizes "${GHOSTFX_BENCH_SIZES:-1920x1080,2560x1440,3440x1440,3840x2160}" --frames "${GHOSTFX_BENCH_FRAMES:-20}" --json)
if [[ -n "${GHOSTFX_BENCH_ALL:-}" ]]; then args+=(--all); else args+=("${ids[@]}"); fi
out=${GHOSTFX_BENCH_OUT:-benchmarks/results.json}
PYTHONPATH=tools python3 -m ghostfx benchmark "${args[@]}" > "$out.raw"
python3 - "$out.raw" "$out" <<'PY'
import json, sys, datetime, platform
raw = json.load(open(sys.argv[1]))
renderer = next(iter(next(iter(raw.values())).values()))["renderer"]
soft = any(k in renderer.lower() for k in ("llvmpipe", "softpipe", "swiftshader", "software"))
out = {
    "date": datetime.date.today().isoformat(),
    "renderer": renderer,
    "host": platform.machine(),
    "note": "software rasteriser: CPU-bound, use for relative ranking only" if soft else "GPU timer queries",
    "method": "ghostfx benchmark: GL_TIME_ELAPSED per frame, balanced preset, terminal fixture as iChannel0",
    "shaders": raw,
}
json.dump(out, open(sys.argv[2], "w"), indent=2)
print(f"wrote {sys.argv[2]} ({len(raw)} shaders, {renderer})")
PY
rm -f "$out.raw"
