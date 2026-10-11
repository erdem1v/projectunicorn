#!/usr/bin/env bash
# Renders every menu frame (4 in parallel). The _1536 frames are 1536x864 logical at x1.25 = 1920x1080 PNG.
cd "$(dirname "$0")/.."
R="$(cd ../.. && pwd)/tools/render.sh"
ls *.html | xargs -P 4 -I{} bash -c '
  f="{}"; b="${f%.html}"
  case "$b" in *_1536) bash "$0" "$f" "$b.png" 1536 864 1.25 ;; *) bash "$0" "$f" "$b.png" 1920 1080 ;; esac' "$R"
