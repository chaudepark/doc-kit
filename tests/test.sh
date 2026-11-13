#!/bin/sh
# The committed kit is what the source builds; the sample passes the check; a page off the kit fails it;
# explainer builds kit pages; the imported skills' own tests pass.
set -eu
cd "$(dirname "$0")/.."
dockit=skills/doc-kit/scripts/dockit
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT

sh scripts/build-kit.sh "$tmp/kit.css" 2>/dev/null
cmp "$tmp/kit.css" skills/doc-kit/kit.css || { echo "kit.css is behind src/: pnpm build" >&2; exit 1; }
python3 $dockit wrap src/sample.html -o "$tmp/sample.html" --title "doc-kit sample" --lang en
cmp "$tmp/sample.html" skills/doc-kit/sample.html || { echo "sample.html is behind src/: pnpm build" >&2; exit 1; }
python3 $dockit check skills/doc-kit/sample.html

# a class off the kit, and a picture's class named like a kit part: both must fail
printf '<p class="text-[13px]">x</p>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/off.html" --title off
python3 $dockit check "$tmp/off.html" 2>"$tmp/err" && { echo "check passed a class off the kit" >&2; exit 1; }
grep -q 'text-\[13px\]' "$tmp/err"
printf '<svg><rect class="btn"/></svg>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/clash.html" --title clash
python3 $dockit check "$tmp/clash.html" 2>"$tmp/err" && { echo "check passed a picture class that is a kit part" >&2; exit 1; }
grep -q 'btn' "$tmp/err"
# a page with its own classes defined in its own CSS passes
printf '.cont-input { fill: #d9822b }' > "$tmp/own.css"
printf '<svg><rect class="cont-input"/></svg>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/own.html" --title own --css "$tmp/own.css"
python3 $dockit check "$tmp/own.html"
# a card and its screen in different words fail; in the same words they pass
printf '<div class="doc-home"><a class="card" href="#bass"><h3 class="card-title">move the bass</h3></a></div><section class="doc-view" id="bass"><h2>Bass motion</h2></section>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/names.html" --title names
python3 $dockit check "$tmp/names.html" 2>"$tmp/err" && { echo "check passed a card and a screen in different words" >&2; exit 1; }
grep -q 'Bass motion' "$tmp/err"
printf '<div class="doc-home"><a class="card" href="#bass"><h3 class="card-title">move the bass</h3></a></div><section class="doc-view" id="bass"><h2>move the bass</h2></section>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/names.html" --title names
python3 $dockit check "$tmp/names.html"
# a figure made elsewhere keeps its tool's classes
printf '<figure class="doc-fig"><svg><g class="edgePath"/></svg></figure>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/fig.html" --title fig --prose
python3 $dockit check "$tmp/fig.html"

# a page's text for the readers: headings marked, pictures as their labels, no markup, no CSS
python3 $dockit text skills/doc-kit/sample.html > "$tmp/sample.txt"
grep -q '^# A page is made of these parts only$' "$tmp/sample.txt" && grep -q '^## Values side by side$' "$tmp/sample.txt" \
  && grep -q '^\[picture: the input\]$' "$tmp/sample.txt" || { echo "dockit text lost a heading or a picture's label" >&2; exit 1; }
if grep -q '[<{]' "$tmp/sample.txt"; then echo "dockit text left markup or CSS in the text" >&2; exit 1; fi
printf '<body><!-- a > b --><h2 title="a > b">One\nheading</h2><table><tr>\n<th>Key</th>\n<td>un<em>believ</em>able</td>\n</tr></table><figure><svg><svg><text>leak</text></svg><text>leak</text></svg><figcaption>Caption</figcaption></figure><img alt="a chart"><pre>a\n  b</pre></body>' > "$tmp/odd.html"
python3 $dockit text "$tmp/odd.html" > "$tmp/odd.txt"
printf '## One heading\n\nKey | unbelievable |\n\n[picture]\n\nCaption\n\n[picture: a chart]\n\na\n  b\n' | cmp - "$tmp/odd.txt" || { echo "dockit text: nesting, a table, inline tags, a comment or code came out wrong" >&2; cat "$tmp/odd.txt" >&2; exit 1; }
# explainer's page builder gives a kit page: a sample document built with it passes the check
node skills/explainer/scripts/build-html.mjs docs/figure-cheatsheet/README.md >/dev/null
python3 $dockit check docs/figure-cheatsheet/dist/index.html
# the page's language comes from its prose: the English page quotes Japanese tool output and stays English
grep -q '<html lang="en">' docs/figure-cheatsheet/dist/index.html || { echo "the English sample was not built as lang=en" >&2; exit 1; }
node skills/explainer/scripts/build-html.mjs docs/figure-cheatsheet/README.ja.md >/dev/null
python3 $dockit check docs/figure-cheatsheet/dist/README.ja.html
grep -q '<html lang="ja">' docs/figure-cheatsheet/dist/README.ja.html || { echo "the Japanese sample was not built as lang=ja" >&2; exit 1; }
grep -q 'href="../README.ja.md"' docs/figure-cheatsheet/dist/index.html || { echo "the link to the other language does not point beside the source" >&2; exit 1; }
# dockit reads the language the same way: kana inside <pre> or <code> is not prose
printf '<p>English text</p><pre><code>\343\201\213\343\201\252</code></pre>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/lang.html" --title lang
grep -q '<html lang="en">' "$tmp/lang.html" || { echo "dockit read the language from code" >&2; exit 1; }
printf '<p>\343\201\213\343\201\252</p>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/lang.html" --title lang
grep -q '<html lang="ja">' "$tmp/lang.html" || { echo "dockit did not read kana in prose as ja" >&2; exit 1; }
# the imported skills: their own tests that need no browser and no d2
node --test tests/d2/*.test.mjs >"$tmp/d2.log" 2>&1 || { tail -20 "$tmp/d2.log" >&2; exit 1; }
python3 tests/first-reader/test_cjk.py >/dev/null
python3 tests/first-reader/test_first_reader.py >/dev/null
echo ok
