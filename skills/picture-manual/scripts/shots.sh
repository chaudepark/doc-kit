#!/bin/sh
# Screenshots of a local HTML page as a reader sees it: desktop width and phone width, with a headless
# Chromium-family browser. Only the first screen is captured (a headless shot does not scroll): raise --height
# to see further down the page.
# usage: shots.sh <page.html> <out dir> [--height <px>] [--theme light|dark]
#   --theme: for a page that switches by data-theme on <html>; a copy with that attribute is rendered.
#   Without it the page follows the system's colour scheme.
# Writes <out dir>/desktop[-<theme>].png (1400 wide) and phone[-<theme>].png (500 wide, the narrowest a headless
# window goes).
set -eu
[ $# -ge 2 ] || { sed -n '2,9p' "$0" >&2; exit 2; }
page=$1; out=$2; shift 2
height=2400; theme=""
while [ $# -gt 0 ]; do
  case "$1" in
    --height) height=$2; shift 2 ;;
    --theme) theme=$2; shift 2 ;;
    *) echo "shots.sh: unknown option $1" >&2; exit 2 ;;
  esac
done
[ -f "$page" ] || { echo "shots.sh: no such page: $page" >&2; exit 1; }
browser=""
for b in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
         "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
         "/Applications/Chromium.app/Contents/MacOS/Chromium"; do
  [ -x "$b" ] && { browser=$b; break; }
done
[ -n "$browser" ] || browser=$(command -v chromium || command -v google-chrome || true)
[ -n "$browser" ] || { echo "shots.sh: no Chromium-family browser found" >&2; exit 1; }
mkdir -p "$out"
abs=$(cd "$(dirname "$page")" && pwd)/$(basename "$page")
suffix=""
if [ -n "$theme" ]; then
  # the copy sits beside the page so its relative links still work; it goes to the Trash after
  copy="$(dirname "$abs")/.shots-$theme-$$.html"
  sed "s/<html\([^>]*\)>/<html\1 data-theme=\"$theme\">/" "$abs" > "$copy"
  abs=$copy; suffix="-$theme"
fi
for view in desktop:1400 phone:500; do
  name=${view%%:*}; width=${view##*:}
  "$browser" --headless=new --disable-gpu --hide-scrollbars --window-size="$width,$height" \
    --screenshot="$out/$name$suffix.png" "file://$abs" >/dev/null 2>&1
  [ -s "$out/$name$suffix.png" ] || { echo "shots.sh: no screenshot for $name" >&2; exit 1; }
  echo "$out/$name$suffix.png"
done
if [ -n "$theme" ]; then mv "$copy" "$HOME/.Trash/" 2>/dev/null || true; fi
