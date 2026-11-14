---
name: doc-kit
description: The house look for standalone HTML document pages — manuals, cheat sheets, how-to pages, explainers, reports, research notes — in any of the user's repositories. One prebuilt CSS (daisyUI 5 on Tailwind 4) and a fixed list of parts, so every page has the same fonts, sizes and layout and none is designed from scratch. It decides how a page looks, not what goes on it: for a tool's manual or cheat sheet (マニュアル, 早見表, チートシート, 使い方のページ) the picture-manual skill decides the content, for an explanation to a reader (説明ページ) the explainer skill does, and both take their look from here. Use it together with them, or alone when the content is already decided (a report, research notes, レポート as HTML, a 手順書 that is already written), when you restyle or review a page, or when the user says pages look different from each other (見た目を揃えたい, デザインシステム). Whichever skill the request reaches, the page is checked, looked at and read by simulated readers (the first-reader skill) before it is handed over; the user does not ask for any of that. Not for slides (the d2-slides skill keeps a deck's own look), a web app or site with its own design, nor for Markdown.
---

# doc-kit

A page looks like the others because it is made of the same few parts, not because someone designed it well that
day. So the rule is one: **a page uses only the parts in `sample.html`**. Fonts, text sizes, spacing, the page's
width and the colours are the kit's; a page does not set them. Every page is dark (the user finds a light page
glaring), whatever the system is set to.

This skill is the look only. What goes on a page is another skill's: `picture-manual` for how to use a tool (a
manual, a cheat sheet), `explainer` for an explanation to one reader (a concept, a change, a result). When one of
them fits, it leads and this skill gives the page its parts; alone, this skill is for a page whose content is
already decided. Two things keep a look of their own: a slide deck (`d2-slides`), which is a fixed frame
shown one at a time, not a page that is read; and the page `first-reader` builds of a read, from its own template
(a tool's record of one run, not a document someone wrote). Do not put `kit.css` on either, nor their styles on a
page.

## Every page goes the same way

Anyone can use this without thinking: that is what the kit is for. The user says what they want and nothing
else: no flag, no skill's name, no "and check it". There is one way through, and it is the best the kit has:
nothing below is a mode, a level or an option that the user or you pick, and what a page gets does not depend on
how it was asked for. Where a step depends on the page (its language, its shape), the script or a fixed rule
decides. If you find yourself choosing between two commands or two depths, the kit is wrong there: say so in the
hand-over instead of choosing quietly. Whichever skill of this plugin the request reaches first, the page goes
through all of these, in this order, without being asked:

1. **What goes on it.** How to use a tool (a manual, a cheat sheet, a how-to): read the `picture-manual` skill
   now and follow it. An explanation for a reader (a concept, a change, a result): the `explainer` skill
   (`explainer-book` when it needs chapters). Content that is already written: go on.
   A page in Japanese, whichever skill leads: read the bundled `yomiyasu` skill (`../yomiyasu/SKILL.md`,
   「1. 基本原則」) before writing its words, and write them by it. Every Japanese page, every time.
2. **Figures.** A diagram of boxes and lines or a chart is made and checked as the explainer skill's
   `references/figures.md` says (a D2 diagram: the `d2-diagram` skill) and placed as `doc-fig`. A picture of
   what a tool does is drawn from the tool's real output (picture-manual).
3. **The look.** The parts below, then `dockit wrap` and `dockit check` ("Make a page").
   `check` also reads a Japanese page's words with yomiyasu's lint and prints the places it names; it tells
   the language and the kind of page by itself. Rewrite every place by that skill's rule for it (the meaning,
   the conditions and the strength of a claim stay as they were; nothing is added), then run `check` once
   more. A place that is right as it stands (a fixed term, a literal meaning) is named in the hand-over with
   its reason. The places it names do not fail the page, and their number is not a score; a Japanese page the
   lint could not read does fail.
4. **Look at it** at desktop and phone width, and read the images.
5. **Have it read.** The `first-reader` skill reads the page before the user does. A wide page (cards, a
   manual, a cheat sheet) is read by lookup: its readers come with a wish and look for it, first in a
   screen's abstract and only then in the screen; and its pictures are read one at a time, each by a reader
   who is shown that picture without its neighbours and says which line is its own. The whole procedure is
   `../first-reader/references/lookup.md` (short; nothing else of that skill is needed);
   `python3 scripts/dockit lookup page.html -o <run dir>` gives the words as such a reader meets them, and
   `python3 scripts/dockit pictures page.html -o <run dir>/pictures` the pictures. A prose
   page gets first-reader's full read; its text is the source Markdown when there is one, otherwise
   `python3 scripts/dockit text page.html > page.txt`. The readers are fresh subagents (you have seen the
   page, they have not). Fix what they stumbled on, run the check again, and have the same readers (new
   subagents, the same personas) read once more; what still stumbles after that goes in the hand-over, not
   into a third round. The page first-reader builds of the read stays beside the run: do not publish it or open it,
   give its path. (A book: at least its first chapter and the chapters with exercises, as explainer-book says.
   A trial shown to the user to settle a shape is not read: the user is its reader.)
6. **Hand it over**: the page's path, what the readers said in two or three lines and what you changed for
   it, and what you did not check.

Step 5 is left out only when the page says and shows what it did at its last read. For a page read by lookup,
`dockit lookup` prints a mark of its words and pictures (`mark 3f2a…`), the readers file keeps the mark of each
read, and the same mark means neither changed (a restyle, a rebuilt kit). For a prose page from Markdown: its
source file is the same as at the commit of its last read. Anything else is read, however small the change
looks: a typo, a comma the lint named, a redrawn picture. Say which step you left out, and why. Nothing else is optional: a page
that skipped a step is not finished, however good it looks.

What holds a page to this, said plainly, because the hand-over must not claim more:

- **A script stops it**: `dockit check`, and only that: the classes, `style=`, the kit's copy, a picture's
  class, a card's and its screen's headings, a screen without a short abstract, the ordinary ways a page
  fetches from outside. It stops a page where it is
  run: here that is you, in step 3; in a repository that builds pages, put it in that repository's tests.
  Inside a `doc-fig` figure it does not ask that classes be defined and lets `style=` be. It reads
  well-formed markup and plainly written CSS, and does not see what a script does when it runs: a check on
  a page written in good faith, not a wall.
- **You are asked, and nothing notices if you do not**: going through the six steps at all, writing Japanese
  by yomiyasu's rules and rewriting what its lint names (`check` prints the places; it does not stop for
  them), looking at the screenshots, the read, and the parts' rules `check` does not read (a `<thead>`, a
  picture's label, a way back from a screen). That is why step 6 says what was not done.
- **Nobody checks**: whether a person finds the page easy to read, or sees in a picture what the picture's
  reader (a model, choosing among four lines) saw. A read without a stumble is not evidence: the page, the
  wishes and the verdicts come from the same kind of model, and one read is one sample. Do not tell the user a page "reads well"; tell them what was
  found and fixed.

In this skill's directory:

- `sample.html`: every part, on one page. Open it (or read its source) before writing; copy the markup from it.
- `kit.css`: the built CSS. Never edit it, never write a second one.
- `scripts/dockit`: makes a page (`wrap`), checks one (`check`), and gives a page's text for the readers
  (`text`; `lookup` and `pictures` for a page read by lookup, `grade` for what the pictures' readers
  chose). Python 3.9+, nothing to install.

## Make a page

1. Write the body only (what goes inside `<main>`), from the parts below.
2. `python3 scripts/dockit wrap body.html -o page.html --title "…" [--css own.css] [--prose] [--lang en]`
   One self-contained file: it opens from `file://`, offline, on a phone. The page's language is read from the
   body's prose (kana outside `<pre>` and `<code>`: `ja`, otherwise `en`) unless `--lang` says it; write the page in the reader's language.
3. `python3 scripts/dockit check page.html`. Fix what it names; do not ship a page that fails.
   (Inside a `doc-fig` figure the classes need no definition and `style=` is let be: they are the drawing
   tool's. A kit part's name on a picture and a fetch are refused there too.)
4. Look at it at desktop and phone width (`../picture-manual/scripts/shots.sh page.html <out dir>`).

A page written as Markdown: the explainer skill's `build-html.mjs` (same plugin) turns it into a kit page; do
not convert it by hand.

A page that a generator in another repository builds: copy `kit.css` into that repository once, inline it as
`<style data-doc-kit>…</style>`, put the body in `<main class="doc" id="all">`, and run `dockit check` in that
repository's tests. The check says when the copy has fallen behind the kit. Run the plugin's own `dockit`; a
repository that pins the kit takes `skills/doc-kit` and `skills/yomiyasu` together (the check reads a Japanese
page's words with the second, and fails a Japanese page it could not read).

## The parts

| For | Markup |
| --- | --- |
| Title block | `<header>`: a `badge badge-outline badge-primary` (version), `<h1>`, `<p class="doc-lede">`, the screens' links as `tabs tabs-box` > `a.tab` |
| A section | `<section>` with `<h2>`; inside it `<h3>` |
| Small or secondary text | `doc-note` |
| The flow in 3 to 5 pictures | `doc-cards` > `card card-border bg-base-100` > `<figure>` + `card-body` > `card-title` (number as `badge badge-primary`) |
| Wish cards, two columns at most | `doc-cards-2` > `a.card card-border bg-base-100` > `card-body` |
| One line of how | `doc-how`: where as a `badge`, the value in `<code>` |
| Before → after | `doc-ba` > `<div>` (`doc-note` + picture), `<span class="doc-to">→</span>`, `<div>` |
| A setting's values side by side | `<h3 class="doc-sticky">` then `doc-vals` > `figure.doc-pic` > picture + `<figcaption><b>value</b>one line</figcaption>` |
| A setting with five values or fewer | the same, as `doc-vals doc-vals-few`: wider columns, larger pictures |
| Folded detail | `<details class="collapse collapse-arrow border border-base-300 bg-base-100">` > `summary.collapse-title` + `collapse-content` |
| A picture's label | `aria-label` on the `<svg>` (or the value's name in its `<figcaption><b>`): a reader who cannot see it, and the readers of step 5, get the label and nothing else |
| Settings with no picture | `<div class="overflow-x-auto">` > `table.table` with a `<thead>` row that names the columns (without it a row reads as bare values), the setting in `<th>` |
| Good to know / take care | `alert alert-soft alert-info` / `alert alert-soft alert-warning` (with `role="alert"`) |
| Keys | `kbd kbd-sm` |
| Labels | `badge` with `badge-neutral`, `badge-ghost`, `badge-outline` or `badge-soft badge-primary` |
| A screen's abstract | after the screen's `<h2>` and before its detail (the first `<h3>`, table, folded part or `doc-vals`): a `doc-how` line (where, and what to set), with the before → after and one line of what comes out; a screen that only lists things opens with a `doc-lede` sentence instead. It answers the screen's wish by itself, as a paper's abstract does. `check` holds that it is there, says something and is short (at most 400 full-width or 800 Latin characters, so a screen with no `<h3>` at all is short as a whole); whether it answers the wish, the read finds out. What follows is detail, under `<h3>` |
| One screen at a time | home in `doc-home`, each screen a `<section class="doc-view" id="…">` with a way back (`btn btn-ghost btn-sm`); `#all` shows everything. A card that opens a screen and that screen's `<h2>` say the same words (`check` compares them) |
| A page that is prose (from Markdown) | `<main class="doc doc-prose">` (`dockit wrap --prose`), or a `doc-prose` section: one column; bare `<h2>`, `<p>`, lists, `<a>`, `<pre><code>`, `<blockquote>`, `<details>`, `<hr>` |
| A figure made elsewhere (Mermaid, D2, a chart, a screenshot) | `<figure class="doc-fig">` > `<svg>` or `<img>` + `<figcaption>`: it keeps the white ground it was drawn for |
| A book's chapters | `<nav class="doc-book">`: the one before, the contents, the one after |
| In a picture | `doc-bg` (its ground), `doc-hi` (what changed), `doc-dim` (what is only context) |

## What a page may add

Only what belongs to the tool it documents, in its own CSS (`--css`):

- the tool's colours (a track's Role, a signal's kind) and how its pictures are painted;
- `--doc-hi` on `.doc`, the colour of what changed in a picture, when the tool's colours are near the kit's primary
  (a blue or purple track under an indigo highlight cannot be told apart): `.doc { --doc-hi: #e8954a }`;
- every such class named with the tool's prefix (`cont-bass`, not `bass`): a class called `input`, `btn`, `table`
  or `card` takes the kit part's styles, and `check` refuses it inside a picture.

Not on a page, and `check` refuses each: `style="…"` (give the thing a class in the page's own CSS; a `doc-fig`
figure keeps its tool's); a Tailwind utility the sample does not use (the built CSS does not contain it, so it
does nothing); what the browser would have to fetch: a font, a script, a stylesheet, a frame, a picture in a
file beside the page (put a picture in as `data:`, or draw it as SVG). A page needs no script; `check` reads
markup and CSS, and what a script would fetch when it runs it does not see.

## When a part is missing

Do not improvise it on the page: the next page will improvise it differently. Add it to the kit, in the kit's own
repository (not in an installed copy):

1. Find the daisyUI component for it (its class names: https://daisyui.com/SKILL.md, or `node_modules/daisyui`).
   No component fits: add a `doc-…` class in `src/kit.css`, from the text sizes the kit already uses.
2. Put an example of it in `src/sample.html`; the build keeps only what the sample uses.
3. `pnpm build && pnpm test`, look at the sample, and add its row to the table above. (The build reads the
   sample's class attributes only, so a word in its text never becomes a part.)

Ask the user before adding a part: fewer parts is the point.
