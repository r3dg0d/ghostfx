#!/usr/bin/env bash
# Render a built shader through a real Ghostty instance and capture frames.
#
#   scripts/ghostty-capture.sh SHADER.glsl|- OUT_PREFIX [frames] [interval] [extra ghostty config lines...]
#
# Requires: ghostty, Xvfb (or an existing $DISPLAY), ffmpeg.
# Writes OUT_PREFIX-0.png ... OUT_PREFIX-N.png. Exit 2 if the shader failed to
# load (Ghostty silently ignores broken shaders, so we grep its log).
set -euo pipefail

shader=$1; [[ "$shader" != "-" ]] && shader=$(realpath "$shader"); out=$2; frames=${3:-1}; interval=${4:-1}; shift $(( $# < 4 ? $# : 4 ))
W=${GFX_CAPTURE_W:-1280}; H=${GFX_CAPTURE_H:-720}
here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'kill ${gpid:-} ${xpid:-} 2>/dev/null || true; rm -rf "$tmp"' EXIT

if [[ -z "${GFX_CAPTURE_DISPLAY:-}" ]]; then
  disp="${GFX_CAPTURE_DISPNUM:-:$(( 100 + RANDOM % 400 ))}"
  Xvfb "$disp" -screen 0 "${W}x${H}x24" >/dev/null 2>&1 & xpid=$!
  sleep 1.5
else
  disp=$GFX_CAPTURE_DISPLAY
fi

mkdir -p "$tmp/cfg/ghostty"
{
  if [[ "$shader" != "-" ]]; then
    echo "custom-shader = $shader"
    echo "custom-shader-animation = always"
  fi
  echo "window-decoration = none"
  echo "window-width = 400"
  echo "window-height = 200"
  echo "font-size = ${GFX_CAPTURE_FONT:-13}"
  echo "confirm-close-surface = false"
  echo "cursor-style-blink = false"
  for line in "$@"; do echo "$line"; done
} > "$tmp/cfg/ghostty/config"

DISPLAY=$disp XDG_CONFIG_HOME="$tmp/cfg" "${GHOSTTY:-ghostty}" \
  -e "$here/examples/demo-terminal.sh" 3600 > "$tmp/log" 2>&1 & gpid=$!
sleep "${GFX_CAPTURE_WARMUP:-6}"

if [[ "$shader" != "-" ]] && ! grep -q "loaded custom shader" "$tmp/log"; then
  cat "$tmp/log" >&2; exit 2
fi
if grep -qiE "shader.*(error|fail)|spirv error" "$tmp/log"; then
  grep -iE "shader|spirv" "$tmp/log" >&2; exit 2
fi
if [[ -n "${GFX_CAPTURE_RECORD:-}" ]]; then
  # Record an animated clip instead of stills: OUT_PREFIX.mp4
  ffmpeg -y -loglevel error -f x11grab -draw_mouse 0 -framerate "${GFX_CAPTURE_FPS:-15}" -video_size "${W}x${H}" -i "$disp" \
    -t "$GFX_CAPTURE_RECORD" -pix_fmt yuv420p "$out.mp4"
  cp "$tmp/log" "$out.log"
  exit 0
fi
for ((i = 0; i < frames; i++)); do
  ffmpeg -y -loglevel error -f x11grab -draw_mouse 0 -video_size "${W}x${H}" -i "$disp" -frames:v 1 "$out-$i.png"
  (( i + 1 < frames )) && sleep "$interval"
done
cp "$tmp/log" "$out.log"
