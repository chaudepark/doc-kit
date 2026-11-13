#!/bin/sh
# The page gates of vlmkit on the committed example deck (examples/d2-slides/README.md), and two controls
# that show the gates still stop something. Needs a browser; no d2 (the build is committed).
set -eu
cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT
built=examples/d2-slides/built
v() { pnpm exec vlmkit "$@" >"$tmp/out.txt" 2>&1; }
fail() { echo "deck gates: $1" >&2; tail -15 "$tmp/out.txt" >&2; exit 1; }

v check integrity "$built/index.html" || fail "integrity of index.html"
v check integrity "$built/print.html" --viewports 1280 || fail "integrity of print.html"
v check copy "$built/print.html" --manifest "$built/copy.txt" --allow-invisible unknown || fail "copy of print.html"
v check a11y contrast "$built/print.html" || fail "contrast of print.html"

# A gate that only ever passes proves nothing.
# A line the deck does not say must be reported missing:
cp "$built/copy.txt" "$tmp/copy.txt"
echo "This sentence is on no slide of the deck." >> "$tmp/copy.txt"
if v check copy "$built/print.html" --manifest "$tmp/copy.txt" --allow-invisible unknown; then fail "the copy gate passed a line the deck does not say"; fi
grep -q "copy-missing" "$tmp/out.txt" || fail "the copy gate failed, but not with copy-missing"
# A frame too short for its slides must be reported clipped:
cp -R "$built" "$tmp/short"
sed 's/--stage-h: 720px/--stage-h: 260px/' "$built/print.html" > "$tmp/short/print.html"
if cmp -s "$built/print.html" "$tmp/short/print.html"; then fail "the deck no longer sets --stage-h: 720px, so the short-frame control changed nothing"; fi
if v check integrity "$tmp/short/print.html" --viewports 1280; then fail "the integrity gate passed slides cut off by a short frame"; fi
grep -q "clipped-content" "$tmp/out.txt" || fail "the integrity gate failed, but not with clipped-content"
echo "deck gates passed"
