# doc-kit

English | [日本語](README.ja.md)

Skills and tools for the documents an AI writes for people: in a form that **gets read**, and in **one look**.

A coding agent will write any amount of manual and explanation. The trouble is that it is too long to read, and that it looks different every time.
This repository stops Claude from designing a page on the spot. A page is put together from a fixed set of parts, and checked by a script before it is handed over.

The one who uses this is, for the most part, Claude. What a person does is install it, ask, and read the page that comes out.

## Install

A Claude Code plugin. This repository is its own marketplace; the plugin `doc-kit` holds seven skills.

```sh
claude plugin marketplace add chaudepark/doc-kit
claude plugin install doc-kit@doc-kit
```

Inside Claude Code: `/plugin marketplace add chaudepark/doc-kit` and `/plugin install doc-kit@doc-kit`.
To update: `claude plugin marketplace update doc-kit`, then `claude plugin update doc-kit@doc-kit`. Restart running sessions afterwards.

| Skill | You say | Claude does |
|---|---|---|
| `doc-kit` | "put this together as HTML", "make these pages look the same" | builds the page from the parts in the sample only, and checks it with `dockit`. Every other skill's look is this one |
| `picture-manual` | "this manual is hard to follow", "make a cheat sheet" | turns a tool's documentation into cards: what I want → how → what comes out. The pictures are drawn from the tool's real output |
| `explainer` | "explain this PR so that I understand it" | builds a persona of one reader and writes only what that reader does not know. Quoted output and figures are verified by tools |
| `explainer-book` | "make it a tutorial in chapters" | chaptered learning material, checked for objectives, concept order, reading time and exercises |
| `first-reader` | "read this before I publish it" | simulated readers go through the draft paragraph by paragraph, and report where they quit and what they remember the next day. It does not rewrite |
| `d2-diagram` | "an architecture diagram in D2" | a D2 diagram laid out by TALA, held to a fact sheet |
| `d2-slides` | "make slides of this" | an HTML deck with figures from one Markdown file, checked |

What was taken in from other projects is listed in [NOTICE.md](NOTICE.md). The files of `explainer` and `explainer-book` are written in Japanese; they write in the reader's language.

## What it does

```
ask ─→ a skill sets the steps ─→ the body (parts only) ─→ one HTML file ─→ check ─→ look at it
          │                          │                       │               │
     picture-manual            the parts in the        kit.css inlined   dockit check
     explainer, ...            sample (sample.html)    dark only         screenshots
```

- **One look**: `skills/doc-kit/kit.css`, prebuilt from daisyUI 5 and Tailwind CSS 4. Fonts, text sizes (five of them), widths and colours are decided there and nowhere else. Pages are dark only.
- **Only the parts in the sample**: `skills/doc-kit/sample.html` is the list of parts a page may use. The build keeps only the classes the sample uses, so anything else does nothing on a page.
- **Checked**: `dockit check` stops a page that uses a class the sample does not have, carries an old `kit.css`, names a picture's class like a part, heads a screen in other words than the card that opens it, or loads something from outside.
- **One file**: a page opens offline and on a phone. The repository that uses the kit needs no Node and no build (`dockit` is Python 3.9, standard library only).
- **Any language**: a page takes its language from its text (Japanese when it has kana, otherwise English), or from `--lang`. The fonts are the ones Mac, Windows and Linux already have for Latin and Japanese.

A part is added to the sample in this repository, not on a page. The rule is to ask the owner first: few parts is the point.

## The two shapes of a page

| Shape | For | Made with |
|---|---|---|
| Wide (cards and pictures) | manuals, cheat sheets; one screen at a time | write the body, then `dockit wrap` |
| Prose (one column) | explanations, reports, a book's chapters; from Markdown | `explainer`'s `build-html.mjs`, or `dockit wrap --prose` |

```sh
python3 skills/doc-kit/scripts/dockit wrap body.html -o page.html --title "Title" [--css own.css] [--prose] [--lang en]
python3 skills/doc-kit/scripts/dockit check page.html
node skills/explainer/scripts/build-html.mjs docs/<topic>/README.md     # → docs/<topic>/dist/index.html
```

The only CSS a page may bring is its tool's colours and how its pictures are painted (class names carry the tool's prefix).

## What explainer needs

`explainer`'s scripts use the `node_modules` of the repository the document lives in (Node 24+).

```sh
pnpm add -D marked @mizchi/vlmkit playwright mermaid
```

D2 figures need the `d2` CLI, data figures `vega` and `vega-lite`, icons `@iconify-json/lucide` and `@iconify-json/logos`. Turning Markdown into HTML needs `marked` only.

## Working on this repository

```sh
pnpm install
pnpm build          # src/ → skills/doc-kit/kit.css and sample.html
pnpm test           # the built files match src, check works, explainer gives kit pages, the imported tests that need no browser
pnpm exec playwright install chromium && sh scripts/setup-d2.sh   # once, for the next line
pnpm test:figures   # figure-check's regression tests (a browser and d2)
```

The theme and colours are the `@plugin "daisyui"` line of `src/kit.css`; the parts are its `doc-` classes and `src/sample.html`. `skills/doc-kit/kit.css` is never edited by hand.

Known: `figure-check` compares a Mermaid figure with its committed SVG byte for byte, and Mermaid lays text out with the machine's fonts. A figure rendered on one OS reads as stale on another; render it again there with `--write`.

## Layout

| Path | What |
|---|---|
| `src/kit.css`, `src/sample.html` | the look's source: the entry for Tailwind and daisyUI, the `doc-` parts, the sample's body (`src/classes.txt` is made from it) |
| `skills/doc-kit/` | the look as a skill: the built `kit.css` and `sample.html`, `scripts/dockit` (wrap / check) |
| `skills/picture-manual/` | manuals in pictures; `scripts/shots.sh` takes a page's screenshots at desktop and phone width |
| `skills/explainer/`, `skills/explainer-book/` | explanations for one reader, and books; `scripts/build-html.mjs` gives kit pages |
| `skills/first-reader/` | simulated readers (Apache-2.0) |
| `skills/d2-diagram/`, `skills/d2-slides/` | D2 diagrams and decks |
| `docs/`, `examples/` | sample documents (which figure tool to use, data figures) and a sample deck |
| `tests/` | `test.sh` (the whole) and the imported skills' tests (`d2/`, `figure-check/`, `first-reader/`) |
| `scripts/` | `build-kit.sh`, and `setup-d2.sh` / `setup-tla.sh` (fetch tools into `.tools/`) |
| `.claude-plugin/` | the plugin and marketplace definitions |

## License

[MIT](LICENSE).
What was taken in from other projects keeps its own license: MIT for most of it (`LICENSES/explainer-MIT.txt`), and `skills/first-reader/` is Apache-2.0 (`LICENSE` and `NOTICE` in that directory). [NOTICE.md](NOTICE.md) says what came from where.
