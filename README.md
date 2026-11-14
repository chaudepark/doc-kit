# doc-kit

English | [日本語](README.ja.md)

Skills and tools for the documents an AI writes for people: in a form that **gets read**, and in **one look**.

A coding agent will write any amount of manual and explanation. The trouble is that it is too long to read, and that it looks different every time.
This repository stops Claude from designing a page on the spot. A page is put together from a fixed set of parts, and checked by a script before it is handed over.

The one who uses this is, for the most part, Claude. What a person does is install it, ask, and read the page that comes out.

**Anyone can use it without thinking.** That is the goal, and the reason other projects' skills are gathered here: a manual comes out in the best state the kit can reach, every time. No flag, mode or level changes what you get, and neither you nor Claude is asked to choose between commands: such a choice is a load on whoever has to make it. What depends on the page (its language, its shape) is decided by a script or a fixed rule.

## Install

A Claude Code plugin. This repository is its own marketplace; the plugin `doc-kit` holds eight skills.

```sh
claude plugin marketplace add chaudepark/doc-kit
claude plugin install doc-kit@doc-kit
```

Inside Claude Code: `/plugin marketplace add chaudepark/doc-kit` and `/plugin install doc-kit@doc-kit`.
To update: `claude plugin marketplace update doc-kit`, then `claude plugin update doc-kit@doc-kit`. Restart running sessions afterwards.

You do not name a skill or pass a flag. Say what you want; the skills call each other, and every page is checked by a script, looked at as screenshots, and read by simulated readers before you get it. Which of these a script enforces and which Claude is only asked to do: [What holds, and what does not](#what-holds-and-what-does-not).

| Skill | You say | Claude does |
|---|---|---|
| `doc-kit` | "put this together as HTML", "make these pages look the same" | builds the page from the parts in the sample only, and checks it with `dockit`. The pages the other skills make take this look (a deck from `d2-slides` and the page `first-reader` builds of a read keep their own) |
| `picture-manual` | "this manual is hard to follow", "make a cheat sheet" | turns a tool's documentation into cards: what I want → how → what comes out. The pictures are drawn from the tool's real output |
| `explainer` | "explain this PR so that I understand it" | builds a persona of one reader and writes only what that reader does not know. Quoted output and figures are verified by tools |
| `explainer-book` | "make it a tutorial in chapters" | chaptered learning material, checked for objectives, concept order, reading time and exercises |
| `first-reader` | "read this before I publish it" | simulated readers go through the draft paragraph by paragraph, and report where they quit and what they remember the next day. It does not rewrite |
| `d2-diagram` | "an architecture diagram in D2" | a D2 diagram laid out by TALA, held to a fact sheet |
| `d2-slides` | "make slides of this" | an HTML deck with figures from one Markdown file, checked |
| `yomiyasu` | "polish this Japanese with yomiyasu" | rewrites AI-written Japanese keeping its meaning, and compares the rewrite with the original. You do not have to say this: every Japanese page the other skills make (a deck is not a page) is written by its rules, and `dockit check` reads the page's words with its lint and prints the places to rewrite. A copy of [nanaism/yomiyasu](https://github.com/nanaism/yomiyasu) |

Which one takes what: how to use a tool goes to `picture-manual`; understanding a concept, a change or a result goes to `explainer`; `doc-kit` is the look of both, and works alone on a page whose content is already decided.

What was taken in from other projects is listed in [NOTICE.md](NOTICE.md). The files of `explainer` and `explainer-book` are written in Japanese; they write in the reader's language. `yomiyasu` is in Japanese and is for Japanese text.

## What it does

```
ask ─→ a skill sets the steps ─→ the body (parts only) ─→ one HTML file ─→ check ─→ look at it ─→ have it read
          │                          │                       │               │                      │
     picture-manual            the parts in the        kit.css inlined   dockit check          first-reader
     explainer, ...            sample (sample.html)    dark only         screenshots           (simulated readers)
```

- **One look** for pages that are read (two exceptions: a slide deck, and the page `first-reader` builds of a read): `skills/doc-kit/kit.css`, prebuilt from daisyUI 5 and Tailwind CSS 4. Fonts, text sizes (five of them), widths and colours are decided there and nowhere else. Pages are dark only.
- **Only the parts in the sample**: `skills/doc-kit/sample.html` is the list of parts a page may use. The build keeps only the classes the sample uses, so anything else does nothing on a page.
- **Checked**: `dockit check` stops a page that uses a class no style defines (the kit holds only the sample's) or a `style=` attribute, carries an old `kit.css`, names a picture's class like a part, heads a screen in other words than the card that opens it, opens a screen without a short abstract, or would make the browser fetch what is not in the file.
- **Read before you read it**: `first-reader`'s simulated readers go through every page (a manual by lookup, with the wishes a user would come with: `skills/first-reader/references/lookup.md`; prose from top to bottom; of a book, its first chapter and the chapters with exercises), and what they stumbled on is fixed first. It is left out only when the page says the same words as at its last read (a restyle, a rebuilt kit). The read finds defects; it does not show that a page reads well.
- **One file**: a page opens offline and on a phone. The repository that uses the kit needs no Node and no build (`dockit` is Python 3.9, standard library only; taking pictures needs a Chromium-family browser).
- **Any language**: a page takes its language from its text (Japanese when more than one in ten of its prose's letters is kana or kanji, counted against the Latin alphabet; otherwise English; code is not counted). There is no flag for it. The fonts are the ones Mac, Windows and Linux already have for Latin and Japanese.

A part is added to the sample in this repository, not on a page. The rule is to ask the owner first: few parts is the point.

## What holds, and what does not

Three different things stand behind the sentences above, and they are not equally strong.

**A script stops it.**

- `dockit check` refuses a page with a class no style defines, a `style=` attribute, an old `kit.css`, a picture's class named like a part, a card and its screen headed in different words, a screen that does not open with a short abstract (the whole answer before the detail, as a paper's abstract: at most 400 full-width or 800 Latin characters), or the ordinary ways a page fetches from outside: a `src`, a `srcset`, a frame, a `<link>`, an `@import`, a `url()` that is neither `data:` nor `#id`, a `<meta>` refresh. It reads the markup with an HTML parser, so in well-formed markup a comment or a script's text does not count.
- It stops a page where it is run. Claude runs it on every page; a repository that builds pages puts it in its own tests.
- Inside a `doc-fig` figure (a diagram another tool made) it does not ask that classes be defined, and lets `style=` be; a kit part's name on a picture and a fetch are refused there too.
- It checks a page written in good faith; it is not a wall against one written to get past it. What an inline script does when it runs, an escaped CSS keyword, an `image-set()` of bare strings, markup that only a browser's parser untangles, or a class named only inside an attribute selector or a function gets by. Python 3.9's parser and a current one disagree on some malformed markup.
- This repository's tests hold the committed CSS to its source, and the `kit` workflow holds a dependency update to the sample page's pixels: 14 pictures, two widths, Chromium. Not hover, focus, a heading that sticks while scrolling, or another browser.

**Claude is asked, and nothing notices a skipped step.**

- Going through the steps at all, writing Japanese by `yomiyasu`'s rules and rewriting the places its lint names (`dockit check` prints them for every Japanese page; it does not stop a page for them, and fails only a Japanese page it could not read), looking at the screenshots, the read by simulated readers, and the parts' rules `check` does not read (a table's head row, a picture's label, a way back from a screen). A skill is a prompt.
- So the hand-over has to say what was not done. How often the whole path is followed without being asked has not been measured.

**Nobody checks.**

- Whether a person sees in a picture what its reader saw. The pictures of a manual are read one at a time by a model that is shown a picture without its neighbours and chooses its line among theirs (`dockit pictures`, `dockit grade`): a miss is a finding, but one right choice in four is right by chance, and no person has been compared with that reader.
- Whether a reader in a hurry is served. There is no separate "tired reader": every screen opens with an abstract that `dockit check` keeps short, and the readers answer from the abstract first. Whether a short abstract is a good one, only the read says.
- Whether a person finds a page easy to read. There is no measurement against human readers and no benchmark. The page, the readers' wishes and the verdicts come from the same kind of model, and one read is one sample. What the readers find is real, and is fixed; what they do not find proves nothing.

What was actually run: the read by lookup was worked out on one real manual (two readers, ten wishes, two rounds), and its written procedure was tried once from nothing, before its later revisions. The abstract-first read and the read of the pictures are new in 0.5.0: the commands were run on two real manuals, and no reader has gone through them yet. `yomiyasu` brings its own measurements and limits, in [its repository](https://github.com/nanaism/yomiyasu/blob/main/docs/limitations.md): its checks find fixed shapes, and whether a text reads well is left to a person there too.

## The two shapes of a page

| Shape | For | Made with |
|---|---|---|
| Wide (cards and pictures) | manuals, cheat sheets; one screen at a time | write the body, then `dockit wrap` |
| Prose (read in order) | explanations, reports, a book's chapters; from Markdown | `explainer`'s `build-html.mjs`, or `dockit wrap` (a body without a `<section>`) |

```sh
python3 skills/doc-kit/scripts/dockit wrap body.html -o page.html
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
sh scripts/setup-d2.sh   # once, for the next line
pnpm test:figures   # figure-check's regression tests, the example deck's page gates and the pictures quiz (a browser and d2)
```

`pnpm install` sets a pre-commit hook (`.githooks/pre-commit`) that runs `pnpm test`. GitHub Actions runs both test commands on every push and pull request (`.github/workflows/test.yml`). Renovate keeps the dependencies up to date (`renovate.json`): it merges by itself what the checks can vouch for. For the kit's own (daisyUI, Tailwind), the `kit` workflow rebuilds `kit.css` on the update's branch and lets it through when the sample page looks the same before and after, pixel for pixel (`scripts/look.mjs`); a look that changed waits for a person, with the pictures. The tools the sample documents quote are updated only when asked for on the Dependency Dashboard, because that means measuring again.

The theme and colours are the `@plugin "daisyui"` line of `src/kit.css`; the parts are its `doc-` classes and `src/sample.html`. `skills/doc-kit/kit.css` is never edited by hand.

Known: `figure-check` compares a Mermaid figure with its committed SVG byte for byte, and Mermaid lays text out with the machine's fonts. A figure rendered on one OS reads as stale on another; render it again there with `--write`.

## Layout

| Path | What |
|---|---|
| `src/kit.css`, `src/sample.html` | the look's source: the entry for Tailwind and daisyUI, the `doc-` parts, the sample's body (`src/classes.txt` is made from it) |
| `skills/doc-kit/` | the look as a skill: the built `kit.css` and `sample.html`, `scripts/dockit` (wrap / check / text / lookup / pictures / grade) |
| `skills/picture-manual/` | manuals in pictures; `scripts/shots.sh` takes a page's screenshots at desktop and phone width |
| `skills/explainer/`, `skills/explainer-book/` | explanations for one reader, and books; `scripts/build-html.mjs` gives kit pages |
| `skills/first-reader/` | simulated readers (Apache-2.0) |
| `skills/d2-diagram/`, `skills/d2-slides/` | D2 diagrams and decks |
| `skills/yomiyasu/` | rewriting AI-written Japanese, and its lint (MIT). A copy, not edited here: `scripts/take-yomiyasu.sh` takes it again from the fork |
| `docs/`, `examples/` | sample documents (which figure tool to use, data figures) and a sample deck; each has `README.md` (English) and `README.ja.md` |
| `tests/` | `test.sh` (the whole) and the imported skills' tests (`d2/`, `figure-check/`, `first-reader/`; yomiyasu's own are in its repository), `deck-gates.sh` (the example deck's page gates) and `pictures.sh` (the pictures quiz, with a browser) |
| `scripts/` | `build-kit.sh`, `look.mjs` (pictures of a page, to compare a look before and after), `take-yomiyasu.sh`, and `setup-d2.sh` / `setup-tla.sh` (fetch tools into `.tools/`) |
| `.claude-plugin/` | the plugin and marketplace definitions |
| `.github/`, `.githooks/`, `renovate.json` | the checks on a push and a pull request, the check before a commit, the dependency updates |

## License

[MIT](LICENSE).
What was taken in from other projects keeps its own license: MIT for most of it (`LICENSES/explainer-MIT.txt`), and `skills/first-reader/` is Apache-2.0 (`LICENSE` and `NOTICE` in that directory), `skills/yomiyasu/` is MIT (`LICENSE` and `UNICODE-LICENSE.txt` in that directory). [NOTICE.md](NOTICE.md) says what came from where.
