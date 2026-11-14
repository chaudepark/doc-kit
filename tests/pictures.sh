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
  result"><rect width="9" height="9"/></svg></figure><div class="card-body"><h3 class="card-title">Hear it</h3></div></div></div><div class="doc-vals"><figure class="doc-pic"><svg viewBox="0 0 10 10"><rect width="3" height="3"/></svg><figcaption>a small square</figcaption></figure></div>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/flow.html" --title flow 2>/dev/null
mkdir -p "$tmp/flow/quiz-notes" && echo mine > "$tmp/flow/quiz-notes/a.md"
DOCKIT_BROWSER="$tmp/browser" python3 $dockit pictures "$tmp/flow.html" -o "$tmp/flow" >/dev/null
DOCKIT_BROWSER="$tmp/browser" python3 $dockit pictures "$tmp/flow.html" -o "$tmp/flow" > "$tmp/out2"
# (the first card's picture stands again among the values, with a caption: it is asked about once, as the captioned one)
[ "$(cut -f 3 "$tmp/flow/key.tsv" | tr '\n' '|')" = "Press play|the result|a small square|" ] || { echo "dockit pictures: a card's picture is held to the wrong words, or the same picture is asked about twice" >&2; cat "$tmp/flow/key.tsv" >&2; exit 1; }
[ -f "$tmp/flow/quiz-notes/a.md" ] || { echo "dockit pictures: removed a directory it did not make" >&2; exit 1; }
# pictures are taken twice as sharp as the window is wide
[ "$(python3 -c 'import struct, sys; print(struct.unpack(">I", open(sys.argv[1], "rb").read()[16:20])[0])' "$(ls "$tmp/flow"/quiz-*/pic-001.png)")" -eq 1000 ] || { echo "dockit pictures: a picture is not 1000 pixels wide" >&2; exit 1; }
grep -q '1 stand on the page a second time' "$tmp/out2" && grep -q 'Load a file.*the same picture' "$tmp/flow/unasked.txt" || { echo "dockit pictures: the picture that stands twice is not accounted for" >&2; exit 1; }
# wish cards share their "now" and differ in their "then": each is asked against the others; a value that is one
# card's "then" is not offered that card's line, nor the card the value's
now='<svg viewBox="0 0 10 10"><rect width="2" height="2"/></svg>'
card() { printf '<a class="card" href="#v"><div class="card-body"><h3 class="card-title">%s</h3><div class="doc-ba"><div>%s</div><span class="doc-to">to</span><div><svg viewBox="0 0 10 10"><rect width="%s" height="2"/></svg></div></div></div></a>' "$1" "$now" "$2"; }
{ printf '<div class="doc-cards-2">'; card "move the bass" 4; card "hold the bass" 6; card "double the bass" 8; printf '</div>'
  printf '<section class="doc-view" id="v"><h2>Bass</h2><p class="doc-how">Set Bass.</p><div class="doc-vals"><figure class="doc-pic"><svg viewBox="0 0 10 10"><rect width="4" height="2"/></svg><figcaption>approach one note before</figcaption></figure><figure class="doc-pic"><svg viewBox="0 0 10 10"><rect width="9" height="2"/></svg><figcaption>root stays</figcaption></figure></div></section>'; } > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/cards.html" --title cards 2>/dev/null
DOCKIT_BROWSER="$tmp/browser" python3 $dockit pictures "$tmp/cards.html" -o "$tmp/cards" >/dev/null
[ "$(wc -l < "$tmp/cards/key.tsv")" -eq 5 ] || { echo "dockit pictures: a wish card's picture is left out" >&2; cat "$tmp/cards/key.tsv" >&2; exit 1; }
lines_of() { awk -v words="$1" 'BEGIN { RS = "## " } index($0, words) && !done { print; done = 1 }' "$tmp/cards"/quiz-*/quiz.md; }
options_of() { number=$(awk -F '\t' -v words="$1" '$3 == words { print $1 }' "$tmp/cards/key.tsv"); cat "$tmp/cards"/quiz-*/quiz.md | awk -v n="$number" '$1 == "##" { on = ($2 == n) } on && /^[A-D]\. /'; }
options_of "move the bass" | grep -q 'hold the bass' || { echo "dockit pictures: a wish card is not asked against another card" >&2; exit 1; }
if options_of "move the bass" | grep -q 'approach one note'; then echo "dockit pictures: a card is offered the line of the value it ends in" >&2; exit 1; fi
if options_of "approach one note before" | grep -q 'move the bass'; then echo "dockit pictures: a value is offered the line of the card that shows it" >&2; exit 1; fi
echo ok
