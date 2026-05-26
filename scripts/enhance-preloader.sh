#!/usr/bin/env bash
# Re-encode intro preloader to 1080×1920 for sharper fullscreen playback.
# Requires: npm install --no-save @ffmpeg-installer/ffmpeg (or ffmpeg on PATH)

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-$ROOT/web/assets/preloader.mp4}"
OUT="$ROOT/web/assets/preloader.mp4"
BAK="$ROOT/web/assets/preloader-source.mp4"

if command -v ffmpeg >/dev/null 2>&1; then
  FFMPEG=ffmpeg
elif [[ -f "$ROOT/node_modules/@ffmpeg-installer/ffmpeg/package.json" ]]; then
  FFMPEG="$(node -e "console.log(require('$ROOT/node_modules/@ffmpeg-installer/ffmpeg').path)")"
else
  FFMPEG="$(node -e "console.log(require('@ffmpeg-installer/ffmpeg').path)")"
fi

cp "$SRC" "$BAK"
"$FFMPEG" -y -i "$BAK" \
  -vf "scale=1080:1920:flags=lanczos,unsharp=5:5:0.6:5:5:0.0" \
  -c:v libx264 -pix_fmt yuv420p -crf 19 -preset slow -movflags +faststart -an \
  "$OUT"
echo "Wrote $OUT (1080×1920). Source kept at $BAK"
