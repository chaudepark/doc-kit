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
printf '<div class="doc-home"><a class="card" href="#bass"><h3 class="card-title">move the bass</h3></a></div><section class="doc-view" id="bass"><h2>move the bass</h2><p class="doc-how">set Bass</p></section>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/names.html" --title names
python3 $dockit check "$tmp/names.html"
# a figure made elsewhere keeps its tool's classes
printf '<figure class="doc-fig"><svg><g class="edgePath"/></svg></figure>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/fig.html" --title fig --prose
python3 $dockit check "$tmp/fig.html"

# check reads the page as a browser does. refuses/passes: <what it is> <body> <words the refusal must carry> [own css]
wrapped() { printf '%s' "$1" > "$tmp/body.html"; python3 $dockit wrap "$tmp/body.html" -o "$tmp/case.html" --title case ${2:+--css "$2"} 2>/dev/null; }
refuses() {
  wrapped "$2" "${4:-}"
  if python3 $dockit check "$tmp/case.html" 2>"$tmp/err"; then echo "check passed $1" >&2; exit 1; fi
  grep -q -- "$3" "$tmp/err" || { echo "check refused $1, but not for it:" >&2; cat "$tmp/err" >&2; exit 1; }
}
passes() { wrapped "$2" "${3:-}"; python3 $dockit check "$tmp/case.html" || { echo "check refused $1" >&2; exit 1; }; }
# a page is one file: whatever makes the browser fetch is refused, wherever it is written
refuses "a picture from another host" '<img src="https://example.com/a.png" alt="a">' 'img src'
refuses "a picture from a file beside the page" '<img src="shots/a.png" alt="a">' 'img src'
refuses "a srcset" '<img srcset="//example.com/a.png 2x" alt="a">' 'img srcset'
refuses "a frame" '<iframe srcdoc="x"></iframe>' 'iframe'
refuses "a video's source" '<video><source src="v.mp4"></video>' 'source src'
refuses "a video's poster" '<video poster="p.png"></video>' 'video poster'
refuses "a second srcset candidate" '<img srcset="data:image/png;base64,AAAA 1x, https://example.com/a.png 2x" alt="a">' 'img srcset'
refuses "an attribute written twice (a browser takes the first)" '<img src="https://example.com/a.png" src="data:," alt="a">' 'img src'
refuses "a class written twice" '<p class="nope" class="doc-note">x</p>' 'nope'
refuses "a size where an address belongs" '<img srcset="2x" alt="a">' 'img srcset'
refuses "a preload's image set" '<link rel="preload" as="image" imagesrcset="https://example.com/a.png 1x">' 'imagesrcset'
refuses "a cursor from outside" '<svg><rect cursor="url(https://example.com/c.cur), auto"/></svg>' 'url('
printf '@namespace x "a;b"; p { background: url(https://example.com/a.png) } q::after { content: "" }' > "$tmp/ns.css"
refuses "a url() after a namespace whose name holds a semicolon" '<p>x</p>' 'url(' "$tmp/ns.css"
printf 'p { background: url(https://example.com/a.png' > "$tmp/open.css"
refuses "a url() the CSS never closes" '<p>x</p>' 'url(' "$tmp/open.css"
passes "a srcset of data with a width and a height" '<img srcset="data:image/png;base64,AAAA 300w 100h, data:image/png;base64,BBBB 2x" alt="a">'
refuses "a page that sends the reader elsewhere" '<meta http-equiv="refresh" content="0;url=https://example.com/">' 'meta'
refuses "an object" '<object data="x.svg"></object>' 'object'
refuses "an embed" '<embed type="image/svg+xml">' 'embed'
refuses "a base" '<base href="https://example.com/">' 'base href'
refuses "an SVG image" '<svg><image href="a.png"/></svg>' 'image href'
refuses "a script from outside, in single quotes" "<script src='x.js'></script>" 'script src'
refuses "a stylesheet link" '<link rel=stylesheet href=x.css>' 'link href'
printf 'p { background: url(http:/example.com/a.png) }' > "$tmp/one-slash.css"
refuses "url() with one slash" '<p>x</p>' 'url(' "$tmp/one-slash.css"
printf '@import "x.css";' > "$tmp/import.css"
refuses "an @import" '<p>x</p>' '@import' "$tmp/import.css"
refuses "url() in a picture attribute" '<svg><rect fill="url(g.svg#a)"/></svg>' 'url('
passes "what is inside the file" '<img src="data:image/png;base64,AAAA" alt="a"><svg><defs><linearGradient id="g"/></defs><rect fill="url(#g)"/><use href="#g"/></svg><a href="https://example.com/">out</a>'
printf '/* see url(https://example.com/a.png) */ .mine { background: url("data:image/svg+xml,%%3Csvg fill=%%27url(%%23a)%%27/%%3E") }' > "$tmp/data.css"
passes "a data: picture in its own CSS, and a URL in a comment" '<p class="mine">x</p>' "$tmp/data.css"
printf 'p::after { content: "see url(https://example.com/a.png) and @import" } @namespace svg url(http://www.w3.org/2000/svg);' > "$tmp/words.css"
passes "a URL that is only words: in a string, a namespace, a link, a label" '<a href="https://man.example.org/curl(1)">url(1)</a><p title="write url(img.png) here">x</p>' "$tmp/words.css"
passes "markup in a comment or in a script's string" '<!-- <link href="x.css"><p class="nope" style="color:red">x</p> --><script>var s = "<img src=x.png class=\"nope\">";</script><p>x</p>'
# no style= on a page (a figure made elsewhere keeps its own)
refuses "an inline style" '<p style="color:red">x</p>' 'style='
passes "a made figure with inline styles, a figure inside it" '<figure class="doc-fig"><figure><svg><g class="x1" style="fill:red"/></svg></figure><svg><g class="x2" style="fill:red"/></svg></figure>'
# a class is defined by a selector, not by a word in a comment, a string or a URL
printf '/* .ghost */ .real::after { content: ".quoted" } .other { background: url("data:image/png;base64,AA.url") }' > "$tmp/ghost.css"
refuses "a class named only in a comment" '<p class="ghost">x</p>' 'ghost' "$tmp/ghost.css"
refuses "a class named only in a string" '<p class="quoted">x</p>' 'quoted' "$tmp/ghost.css"
refuses "a class named only in the kit's licence line" '<p class="com">x</p>' 'com'
passes "a class its own CSS defines" '<p class="real other">x</p>' "$tmp/ghost.css"
# a card and its screen: single quotes, and a section inside the screen before its heading
refuses "a card and a screen in different words, single-quoted" "<div class='doc-home'><a class='card' href='#bass'><h3 class='card-title'>move the bass</h3></a></div><section class='doc-view' id='bass'><section><p>x</p></section><h2>Bass motion</h2></section>" 'Bass motion'
refuses "a card headed with h2" '<div class="doc-home"><a class="card" href="#bass"><h2 class="card-title">move the bass</h2></a></div><section class="doc-view" id="bass"><h2>Bass motion</h2></section>' 'Bass motion'
refuses "a pair after a heading closed by the wrong tag" '<div class="doc-home"><a class="card" href="#a"><h3 class="card-title">One</h4></a><a class="card" href="#bass"><h3 class="card-title">move the bass</h3></a></div><section class="doc-view" id="a"><h2>One</h2></section><section class="doc-view" id="bass"><h2>Bass motion</h2></section>' 'Bass motion'
# a made figure keeps its classes and styles, but not a kit part's name, and not a fetch
refuses "a kit part's name inside a made figure" '<figure class="doc-fig"><svg><g class="btn"/></svg></figure>' 'btn'
refuses "a fetch inside a made figure" '<figure class="doc-fig"><svg><g style="fill:url(g.svg#a)"/></svg></figure>' 'url('
# a screen opens with its abstract, and an abstract is short
refuses "a screen without an abstract" '<section class="doc-view" id="bare"><h2>One</h2><h3>Detail</h3><p class="doc-how">too late</p></section>' 'without its abstract.*bare'
refuses "an abstract that is a heading line, not an abstract" '<section class="doc-view" id="head"><div class="doc-how"><h2>One</h2></div><p>words</p></section>' 'without its abstract.*head'
long=$(printf 'word %.0s' $(seq 1 250))
refuses "an abstract longer than an abstract" "<section class=\"doc-view\" id=\"long\"><h2>One</h2><p class=\"doc-how\">set it</p><p>$long</p></section>" 'longer than an abstract.*long'
refuses "an abstract with nothing in it" '<section class="doc-view" id="mute"><h2>One</h2><p class="doc-how"></p><table class="table"><tr><td>x</td></tr></table></section>' 'without its abstract.*mute'
refuses "a screen never closed, without an abstract" '<section class="doc-view" id="open"><h2>One</h2><h3>Detail</h3>' 'without its abstract.*open'
wide=$(printf '\343\201\202%.0s' $(seq 1 401))
refuses "an abstract of 401 full-width characters" "<section class=\"doc-view\" id=\"wide\"><h2>One</h2><p class=\"doc-how\">$wide</p></section>" 'longer than an abstract.*wide'
passes "a folded part before the heading, then the abstract" '<section class="doc-view" id="early"><details class="collapse"><summary class="collapse-title">x</summary><div class="collapse-content">y</div></details><h2>One</h2><p class="doc-how">Set it.</p></section>'
passes "a procedure: a short abstract, then the steps, however long" "<section class=\"doc-view\" id=\"steps\"><h2>One</h2><p class=\"doc-how\">Five steps set it up.</p><ol><li>$long</li></ol></section>"
passes "a short abstract, and long detail after it" "<section class=\"doc-view\" id=\"fine\"><h2>One</h2><p class=\"doc-lede\">Set it, and this comes out.</p><h3>Detail</h3><p>$long</p></section>"
# own CSS that would end the style block early is not wrapped
printf 'p{}</STYLE><p>spill</p>' > "$tmp/spill.css"
if python3 $dockit wrap "$tmp/body.html" -o "$tmp/spill.html" --title spill --css "$tmp/spill.css" 2>"$tmp/err"; then echo "wrap took CSS that ends its own style block" >&2; exit 1; fi
grep -q 'style block' "$tmp/err" || { echo "wrap refused the CSS for another reason:" >&2; cat "$tmp/err" >&2; exit 1; }

# a page's text for the readers: headings marked, pictures as their labels, no markup, no CSS
python3 $dockit text skills/doc-kit/sample.html > "$tmp/sample.txt"
grep -q '^# A page is made of these parts only$' "$tmp/sample.txt" && grep -q '^## Values side by side$' "$tmp/sample.txt" \
  && grep -q '^\[picture: the input\]$' "$tmp/sample.txt" || { echo "dockit text lost a heading or a picture's label" >&2; exit 1; }
if grep -q '[<{]' "$tmp/sample.txt"; then echo "dockit text left markup or CSS in the text" >&2; exit 1; fi
printf '<body><!-- a > b --><h2 title="a > b">One\nheading</h2><table><tr>\n<th>Key</th>\n<td>un<em>believ</em>able</td>\n</tr></table><figure><svg><svg><text>leak</text></svg><text>leak</text></svg><figcaption>Caption</figcaption></figure><img alt="a chart"><pre>a\n  b</pre><nav><a>Start</a><a>The end</a></nav></body>' > "$tmp/odd.html"
python3 $dockit text "$tmp/odd.html" > "$tmp/odd.txt"
printf '## One heading\n\nKey | unbelievable |\n\n[picture]\n\nCaption\n\n[picture: a chart]\n\na\n  b\n\n- Start\n- The end\n' | cmp - "$tmp/odd.txt" || { echo "dockit text: nesting, a table, inline tags, a comment, code or a nav came out wrong" >&2; cat "$tmp/odd.txt" >&2; exit 1; }
# a read by lookup: the home before pressing anything (folded parts closed, no screen's text), and each screen
python3 $dockit lookup skills/doc-kit/sample.html -o "$tmp/lookup" >/dev/null
grep -q '^\[folded\] The long steps' "$tmp/lookup/home.txt" || { echo "dockit lookup: a folded part lost its mark" >&2; exit 1; }
if grep -q 'Long steps and a glossary\|The value.s name, and what happens' "$tmp/lookup/home.txt"; then echo "dockit lookup: the home shows what is folded, or a screen's text" >&2; exit 1; fi
grep -q '^## Values side by side$' "$tmp/lookup/screen-values.txt" && grep -q "^hold: The value's name" "$tmp/lookup/screen-values.txt" || { echo "dockit lookup: a screen's text is missing" >&2; exit 1; }
grep -q "^Values side by side$(printf '\t')screen-values.txt$(printf '\t')screen$" "$tmp/lookup/index.txt" || { echo "dockit lookup: the index does not lead from a heading to its file" >&2; exit 1; }
grep -q '^### \[1\] Prepare$' "$tmp/sample.txt" || { echo "dockit text: a badge stuck to the word after it" >&2; exit 1; }
grep -q 'whole answer in a line or two' "$tmp/lookup/abstract-values.txt" || { echo "dockit lookup: a screen's abstract is missing" >&2; exit 1; }
if grep -q "The value.s name" "$tmp/lookup/abstract-values.txt"; then echo "dockit lookup: a screen's abstract runs into its detail" >&2; exit 1; fi
# the mark is the same for the same page, and another when a word or a picture changes
mark() { python3 $dockit lookup "$1" -o "$tmp/marked" | sed -n 's/^mark //p'; }
printf '<body><h2>One</h2><p>word</p><svg><rect width="1"/></svg></body>' > "$tmp/m1.html"
printf '<body><h2>One</h2><p>words</p><svg><rect width="1"/></svg></body>' > "$tmp/m2.html"
printf '<body><h2>One</h2><p>word</p><svg><rect width="2"/></svg></body>' > "$tmp/m3.html"
# the pictures' mark also follows the line a picture is held to, and how the page's own CSS paints it
printf '<body><style>.x{fill:red}</style><figure><svg><rect width="1"/></svg><figcaption>one bar</figcaption></figure></body>' > "$tmp/m4.html"
printf '<body><style>.x{fill:red}</style><figure><svg><rect width="1"/></svg><figcaption>a bar</figcaption></figure></body>' > "$tmp/m5.html"
printf '<body><style>.x{fill:blue}</style><figure><svg><rect width="1"/></svg><figcaption>one bar</figcaption></figure></body>' > "$tmp/m6.html"
m4=$(mark "$tmp/m4.html"); m5=$(mark "$tmp/m5.html"); m6=$(mark "$tmp/m6.html")
[ "${m4##* pictures }" != "${m5##* pictures }" ] && [ "${m4##* pictures }" != "${m6##* pictures }" ] && [ "${m4% pictures *}" = "${m6% pictures *}" ] \
  || { echo "dockit lookup: the pictures' mark must follow a picture's line and the page's own CSS: $m4 / $m5 / $m6" >&2; exit 1; }
m1=$(mark "$tmp/m1.html"); m2=$(mark "$tmp/m2.html"); m3=$(mark "$tmp/m3.html")
[ ${#m1} -eq 40 ] && [ "$m1" = "$(mark "$tmp/m1.html")" ] \
  && [ "${m1% pictures *}" != "${m2% pictures *}" ] && [ "${m1##* pictures }" = "${m2##* pictures }" ] \
  && [ "${m1% pictures *}" = "${m3% pictures *}" ] && [ "${m1##* pictures }" != "${m3##* pictures }" ] \
  || { echo "dockit lookup: a word must change the words' mark alone, a picture the pictures' mark alone: $m1 / $m2 / $m3" >&2; exit 1; }
grep -q "$(printf 'link on the home')" "$tmp/lookup/index.txt" || { echo "dockit lookup: a link on the home has no row in the index" >&2; exit 1; }
grep -q 'Long steps and a glossary' "$tmp/lookup/fold-1.txt" || { echo "dockit lookup: what a folded part holds was written nowhere" >&2; exit 1; }
# the shapes the sample does not have: a screen ends at its own </section> (the footer stays on the home), single
# quotes, a contents list, a part that is open, a card's before-and-after left out at a glance
printf '%s' '<body><main class="doc"><div class="doc-home" id="home"><nav><ul><li><a href="#a">One</a></li></ul></nav><a class="card" href="#a"><h3 class="card-title">One</h3><div class="doc-ba"><div><span>now</span></div></div></a><details><summary>More</summary><p>Hidden words</p></details><details open><summary>Shown</summary><p>Open words</p></details></div><section id='\''a'\'' class='\''doc-view'\''><h2>One</h2><section><p>Inner</p></section><p>Last of one</p></section><footer><p>Foot</p></footer></main></body>' > "$tmp/shapes.html"
python3 $dockit lookup "$tmp/shapes.html" -o "$tmp/shapes" >/dev/null
printf -- '- One\n\n### One [opens a screen]\n\n[folded] More\n\n[folded] Shown\n\nOpen words\n\nFoot\n' | cmp - "$tmp/shapes/home.txt" || { echo "dockit lookup: the home of the odd shapes came out wrong" >&2; cat "$tmp/shapes/home.txt" >&2; exit 1; }
printf '## One\n\nInner\n\nLast of one\n' | cmp - "$tmp/shapes/screen-a.txt" || { echo "dockit lookup: a screen did not end at its own end" >&2; cat "$tmp/shapes/screen-a.txt" >&2; exit 1; }
printf 'Hidden words\n' | cmp - "$tmp/shapes/fold-1.txt" || { echo "dockit lookup: a folded part's text is wrong" >&2; exit 1; }
# a page that is not in screens: each <h2> is a place to land
printf '<body><p>Top</p><h2>First</h2><p>one</p><h2>Second</h2><p>two</p></body>' > "$tmp/plain.html"
python3 $dockit lookup "$tmp/plain.html" -o "$tmp/plain" >/dev/null
printf 'Top\n\n## First [opens a screen]\n## Second [opens a screen]\n' | cmp - "$tmp/plain/home.txt" && printf '## Second\n\ntwo\n' | cmp - "$tmp/plain/screen-2.txt" || { echo "dockit lookup: a page without screens came out wrong" >&2; exit 1; }
# explainer's page builder gives a kit page: a sample document built with it passes the check
node skills/explainer/scripts/build-html.mjs docs/figure-cheatsheet/README.md >/dev/null
python3 $dockit check docs/figure-cheatsheet/dist/index.html
# the page's language comes from its prose: the English page quotes Japanese tool output and stays English
grep -q '<html lang="en">' docs/figure-cheatsheet/dist/index.html || { echo "the English sample was not built as lang=en" >&2; exit 1; }
node skills/explainer/scripts/build-html.mjs docs/figure-cheatsheet/README.ja.md >/dev/null
python3 $dockit check docs/figure-cheatsheet/dist/README.ja.html > "$tmp/words.out"
# check reads a Japanese page's words with the bundled lint, as prose when the page is prose; an English page's it does not
# (the kind is on dockit's own line and again on the lint's: twice means the lint answered)
grep -q 'yomiyasu lint as: article' "$tmp/words.out" && [ "$(grep -c article "$tmp/words.out")" -ge 2 ] || { echo "check did not read a Japanese page's words (the lint's own lines are missing)" >&2; exit 1; }
python3 $dockit check docs/figure-cheatsheet/dist/index.html > "$tmp/words.out"
if [ -s "$tmp/words.out" ]; then echo "check read an English page's words with the Japanese lint" >&2; exit 1; fi
grep -q '<html lang="ja">' docs/figure-cheatsheet/dist/README.ja.html || { echo "the Japanese sample was not built as lang=ja" >&2; exit 1; }
grep -q 'href="../README.ja.md"' docs/figure-cheatsheet/dist/index.html || { echo "the link to the other language does not point beside the source" >&2; exit 1; }
# dockit reads the language the same way: kana inside <pre> or <code> is not prose
printf '<p>English text</p><pre><code>\343\201\213\343\201\252</code></pre>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/lang.html" --title lang
grep -q '<html lang="en">' "$tmp/lang.html" || { echo "dockit read the language from code" >&2; exit 1; }
printf '<p>\343\201\213\343\201\252</p>' > "$tmp/body.html"
python3 $dockit wrap "$tmp/body.html" -o "$tmp/lang.html" --title lang
grep -q '<html lang="ja">' "$tmp/lang.html" || { echo "dockit did not read kana in prose as ja" >&2; exit 1; }
# a wide Japanese page is read as a manual, and what the lint names does not fail it
python3 $dockit check "$tmp/lang.html" > "$tmp/words.out" || { echo "what the lint named failed a page" >&2; exit 1; }
grep -q 'yomiyasu lint as: manual' "$tmp/words.out" || { echo "check did not read a wide Japanese page as a manual" >&2; exit 1; }
# where the output cannot show Japanese, the page still passes and is still read
PYTHONIOENCODING=ascii python3 $dockit check "$tmp/lang.html" > "$tmp/words.out" || { echo "an output that cannot show Japanese failed a page" >&2; exit 1; }
[ "$(grep -c manual "$tmp/words.out")" -ge 2 ] || { echo "the lint's list was lost where the output cannot show Japanese" >&2; exit 1; }
# a dockit taken without skills/yomiyasu beside it fails a Japanese page (its words were not read), and says why
mkdir -p "$tmp/pinned/skills/doc-kit/scripts"
cp skills/doc-kit/kit.css "$tmp/pinned/skills/doc-kit/" && cp $dockit "$tmp/pinned/skills/doc-kit/scripts/"
if python3 "$tmp/pinned/skills/doc-kit/scripts/dockit" check "$tmp/lang.html" 2>"$tmp/err"; then echo "a Japanese page nobody read passed" >&2; exit 1; fi
grep -q 'not read by the yomiyasu lint' "$tmp/err" || { echo "check failed a Japanese page without saying its words were not read" >&2; cat "$tmp/err" >&2; exit 1; }
# NOTICE.md names the commit the copy says it is; the lint answers
test -s skills/yomiyasu/FROM || { echo "skills/yomiyasu/FROM is missing or empty" >&2; exit 1; }
grep -q "$(cat skills/yomiyasu/FROM)" NOTICE.md || { echo "NOTICE.md does not name the commit skills/yomiyasu was taken at" >&2; exit 1; }
python3 -I skills/yomiyasu/scripts/yomiyasu_lint.py --json < docs/figure-cheatsheet/README.ja.md > "$tmp/lint.json"
grep -q '"findings"' "$tmp/lint.json" || { echo "the bundled yomiyasu lint did not answer" >&2; exit 1; }
# what the pictures' readers chose, against the key: the miss is named with what it is and what it was read as
mkdir -p "$tmp/graded/quiz-1"
printf '001\tA\tone bar\n002\tB\ttwo bars\n003\tA\tthree bars\n' > "$tmp/graded/key.tsv"
printf '## 001  x/pic-001.png\n\nA. one bar\nB. two bars\n\n## 002  x/pic-002.png\n\nA. one bar\nB. two bars\n' > "$tmp/graded/quiz-1/quiz.md"
: > "$tmp/graded/quiz-1/pic-002.png"
: > "$tmp/graded/quiz-1/pic-001.png"
mkdir -p "$tmp/graded/quiz-2" && : > "$tmp/graded/quiz-2/pic-003.png" && : > "$tmp/graded/quiz-2/quiz.md"
# lines of number and letter alone, one after the other; a line that names no letter; a second reader who counts from 1
printf '001 A\n**002** A - a single bar\n' > "$tmp/graded/quiz-1/answers.txt"
printf '1 B: its own first, miscounted\n003: a rising line, nothing else\n' > "$tmp/graded/quiz-2/answers.txt"
python3 $dockit grade "$tmp/graded" > "$tmp/graded.out"
grep -q '3 pictures: 1 read as what they are, 1 not, 1 without an answer' "$tmp/graded.out" && grep -q 'is:      two bars' "$tmp/graded.out" && grep -q 'read as: one bar' "$tmp/graded.out" && grep -q 'without an answer: 003' "$tmp/graded.out" \
  && [ "$(grep -c '^  quiz-2: ' "$tmp/graded.out")" -eq 2 ] \
  || { echo "dockit grade: wrong count, a miss not named, or an odd line taken for an answer" >&2; cat "$tmp/graded.out" >&2; exit 1; }
# the imported skills: their own tests that need no browser and no d2
node --test tests/d2/*.test.mjs >"$tmp/d2.log" 2>&1 || { tail -20 "$tmp/d2.log" >&2; exit 1; }
python3 tests/first-reader/test_cjk.py >/dev/null
python3 tests/first-reader/test_first_reader.py >/dev/null
echo ok
