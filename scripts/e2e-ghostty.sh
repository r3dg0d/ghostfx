#!/usr/bin/env bash
# End-to-end check against a real Ghostty: the CLI edits the config, sends
# SIGUSR2, and the running terminal switches shader without a restart.
#   scripts/e2e-ghostty.sh            (needs ghostty, Xvfb, ffmpeg, python3)
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); disp=":${GFX_E2E_DISPLAY:-77}"
trap 'kill ${gpid:-} ${xpid:-} 2>/dev/null || true; rm -rf "$tmp"' EXIT
Xvfb "$disp" -screen 0 1280x720x24 >/dev/null 2>&1 & xpid=$!; sleep 1.5
mkdir -p "$tmp/cfg/ghostty"
cfg="$tmp/cfg/ghostty/config"
printf 'window-decoration = none\nwindow-width = 400\nwindow-height = 200\ncustom-shader-animation = always\n' > "$cfg"
export GHOSTFX_HOME="$tmp/gfx" GHOSTFX_GHOSTTY_CONFIG="$cfg" PYTHONPATH="$here/tools" GHOSTFX_DATA="$here"
gfx() { python3 -m ghostfx "$@"; }
shot() { ffmpeg -y -loglevel error -f x11grab -draw_mouse 0 -video_size 1280x720 -i "$disp" -frames:v 1 "$1"; }

gfx apply classic-crt --preset cinematic --no-reload >/dev/null
DISPLAY=$disp XDG_CONFIG_HOME="$tmp/cfg" "${GHOSTTY:-ghostty}" -e "$here/examples/demo-terminal.sh" 3600 > "$tmp/log" 2>&1 & gpid=$!
sleep 7; shot "$tmp/a.png"
GHOSTFX_GHOSTTY_PID=$gpid gfx apply retro-dos --json | python3 -c 'import json,sys; print("reload:", json.load(sys.stdin)["reload"])'
sleep 4; shot "$tmp/b.png"
GHOSTFX_GHOSTTY_PID=$gpid gfx disable >/dev/null
sleep 4; shot "$tmp/c.png"
python3 - "$tmp" <<'PY'
import sys
from PIL import Image
d = sys.argv[1]
px = lambda f: Image.open(f"{d}/{f}").convert("RGB").getpixel((640, 600))
a, b, c = px("a.png"), px("b.png"), px("c.png")
print("classic-crt bg:", a, " retro-dos bg:", b, " disabled bg:", c)
assert b[2] > b[0] + 60, "retro-dos (VGA blue) not visible after SIGUSR2 reload"
assert abs(c[0] - 40) < 6 and abs(c[2] - 52) < 6, "shader still active after disable"
print("e2e OK: apply -> SIGUSR2 reload -> shader switched; disable -> plain terminal")
PY
grep -c "reloading configuration" "$tmp/log" | xargs echo "Ghostty reload events:"
