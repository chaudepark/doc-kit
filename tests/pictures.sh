#!/bin/sh
# dockit pictures on the sample: each picture alone in a file, a line to choose for each, and grade against
# the key. Needs a browser (the one Playwright installed).
set -eu
cd "$(dirname "$0")/.."
dockit=skills/doc-kit/scripts/dockit
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT
# without its sandbox (a CI runner forbids one), and with a profile of its own (not the machine's)
chrome=$(node -e "console.log(require('playwright').chromium.executablePath())")
printf '#!/bin/sh\nexec "%s" --no-sandbox --user-data-dir="%s/profile" "$@"\n' "$chrome" "$tmp" > "$tmp/browser"
chmod +x "$tmp/browser"
DOCKIT_BROWSER="$tmp/browser" python3 $dockit pictures skills/doc-kit/sample.html -o "$tmp/pics" > "$tmp/out"
grep -q '11 pictures for 4 readers' "$tmp/out" || { echo "dockit pictures: not the sample's 11 pictures for 4 readers" >&2; cat "$tmp/out" >&2; exit 1; }
[ "$(ls "$tmp/pics"/quiz-*/pic-*.png | wc -l)" -eq 11 ] || { echo "dockit pictures: a picture's file is missing" >&2; exit 1; }
# every picture is painted, and each is another picture: eleven files, no two the same (empty windows would be)
[ "$(cksum "$tmp/pics"/quiz-*/pic-*.png | cut -d ' ' -f 1 | sort -u | wc -l)" -eq 11 ] || { echo "dockit pictures: two pictures are the same file (empty?)" >&2; exit 1; }
# a value's picture is asked against its neighbours' lines, and no neighbour is in its reader's own directory
held=$(grep -l "^## .*" "$tmp/pics"/quiz-*/quiz.md | xargs grep -l "hold The value's name" | head -1)
grep -q "restrike A picture is never narrower" "$held" || { echo "dockit pictures: the quiz lacks a value's neighbour's line" >&2; exit 1; }
hold=$(awk -F '\t' '$3 ~ /^hold / { print $1 }' "$tmp/pics/key.tsv"); restrike=$(awk -F '\t' '$3 ~ /^restrike / { print $1 }' "$tmp/pics/key.tsv")
[ "$(dirname "$(ls "$tmp/pics"/quiz-*/pic-$hold.png)")" != "$(dirname "$(ls "$tmp/pics"/quiz-*/pic-$restrike.png)")" ] || { echo "dockit pictures: a reader is shown a picture's neighbour" >&2; exit 1; }
if grep -q 'figcaption\|<svg' "$tmp/pics"/quiz-*/quiz.md; then echo "dockit pictures: markup in the quiz" >&2; exit 1; fi
# every answer as the key has it, number and letter alone, but the first: grade names that one and no other
for quiz in "$tmp/pics"/quiz-*; do
  for picture in "$quiz"/pic-*.png; do
    number=$(basename "$picture" .png | cut -c5-7)
    awk -F '\t' -v n="$number" '$1 == n { if (n == "001") print n, ($2 == "A" ? "B" : "A") ": something else"; else print n, $2 }' "$tmp/pics/key.tsv"
  done > "$quiz/answers.txt"
done
python3 $dockit grade "$tmp/pics" > "$tmp/out"
grep -q '11 pictures: 10 read as what they are, 1 not, 0 without an answer' "$tmp/out" && grep -q 'pic-001.png' "$tmp/out" && grep -q 'saw:     something else' "$tmp/out" \
  || { echo "dockit grade: not the one miss that was planted" >&2; cat "$tmp/out" >&2; exit 1; }
# a card whose title stands after its picture: the picture is held to its own card's title, not the one before;
# a label over two lines stays one line of the key; a directory of the user's that is named quiz-… is left alone
printf '%s' '<div class="doc-cards"><div class="card"><figure><svg viewBox="0 0 10 10"><rect width="3" height="3"/></svg></figure><div class="card-body"><h3 class="card-title">Load a file</h3></div></div><div class="card"><figure><svg viewBox="0 0 10 10"><rect width="6" height="6"/></svg></figure><div class="card-body"><h3 class="card-title">Press play</h3></div></div><div class="card"><figure><svg viewBox="0 0 10 10" aria-label="the
  result"><rect width="9" height="9"/></svg></figure><div class="card-body"><h3 class="card-title">Hear it</h3></div></div></div>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/flow.html" --title flow 2>/dev/null
mkdir -p "$tmp/flow/quiz-notes" && echo mine > "$tmp/flow/quiz-notes/a.md"
DOCKIT_BROWSER="$tmp/browser" python3 $dockit pictures "$tmp/flow.html" -o "$tmp/flow" >/dev/null
DOCKIT_BROWSER="$tmp/browser" python3 $dockit pictures "$tmp/flow.html" -o "$tmp/flow" >/dev/null
[ "$(cut -f 3 "$tmp/flow/key.tsv" | tr '\n' '|')" = "Load a file|Press play|the result|" ] || { echo "dockit pictures: a card's picture is held to the wrong words" >&2; cat "$tmp/flow/key.tsv" >&2; exit 1; }
[ -f "$tmp/flow/quiz-notes/a.md" ] || { echo "dockit pictures: removed a directory it did not make" >&2; exit 1; }
echo ok
