# Notices

doc-kit includes work by others.

## mizchi/explainer (MIT)

Copyright (c) 2026 mizchi. License text: `LICENSES/explainer-MIT.txt`.
Taken from https://github.com/mizchi/explainer at commit ccdd7bacfb47451e38506d837af8a629504960b2 (v0.5.3, 2026-10-10):

- `skills/explainer/`, `skills/explainer-book/`, `skills/d2-diagram/`, `skills/d2-slides/`
- `tests/d2/`, `tests/figure-check/`, `tests/first-reader/`
- `docs/figure-cheatsheet/`, `docs/dataviz/` (two of its sample documents), `examples/`, `scripts/setup-d2.sh`,
  `scripts/setup-tla.sh`

Changed here:

- `skills/explainer/scripts/build-html.mjs`: no CSS of its own; pages take doc-kit's `kit.css` (dark only,
  `doc-prose`, figures as `doc-fig`, tables as daisyUI `table`).
- `skills/explainer/scripts/figure-check.mjs`: its sheet also defines doc-kit's colour names.
- `skills/explainer/references/figures.md`: HTML figures use doc-kit's colour names.
- `skills/explainer/scripts/build-html.mjs` also sets the page's language from its text (`ja` with kana, else `en`).
- `tests/figure-check/run.mjs`: the Mermaid cases render afresh on a copy (a committed Mermaid SVG is byte-equal
  only on the OS it was rendered on).
- `scripts/setup-d2.sh`: picks the download for this OS and CPU and verifies the release's checksum;
  `scripts/setup-tla.sh`: its comment in English.
- Install hints say `pnpm add -D` for `npm i -D`; `examples/d2-slides/README.md`, `tests/d2/d2-slides.test.mjs`
  and the sample documents name `pnpm` commands and `verify-doc.mjs` for `npm run` and `npx`.
- `docs/dataviz/samples/versions.mjs`: finds a package's directory under pnpm's layout too.
- `skills/explainer/SKILL.md`, `skills/d2-slides/SKILL.md`, `skills/d2-diagram/SKILL.md`: sentences on what each
  skill is for beside the others, and on a deck keeping its own look.
- `skills/explainer/scripts/build-html.mjs`: the language is read from prose only (not from code), and a link to
  a Markdown file that is not built with the page points beside the source.
- `docs/figure-cheatsheet/`, `docs/dataviz/`, `examples/d2-slides/`: the document in English (`README.md`) and
  in Japanese (`README.ja.md`). In `docs/` the Japanese is the original and the English a translation; in
  `examples/d2-slides/` the English is the original.
- Skill descriptions and texts no longer point to skills, a CI workflow and an icon that are not in this
  repository.
- Not taken: its personas, evals, and the sample documents written for one named reader.

## first-reader (Apache-2.0)

`skills/first-reader/` is from Shubham Saboo and contributors' awesome-llm-apps, as bundled and changed by the
explainer project. Its `LICENSE` and `NOTICE` are in that directory. Changed here: `README.md` has a note on
where the skill and its tests are in doc-kit, and `README.ja.md` is a Japanese translation of it (recorded in
that `NOTICE` too).

## nanaism/yomiyasu (MIT)

`skills/yomiyasu/` is the skill directory of https://github.com/nanaism/yomiyasu, taken through the fork
https://github.com/chaudepark/yomiyasu at commit db78b9bc5e868549b517a037df7a4d1c93edac23 (v3.1.0, 2026-11-12)
with `scripts/take-yomiyasu.sh`. Its `LICENSE` and `UNICODE-LICENSE.txt` are in that directory. Nothing in it is
changed here (the one added file, `FROM`, holds the commit's id): a change is made in the fork and taken again.
That project's own repository is where to get the skill by itself, and has its documentation, its tests and its
measurements. As it notes, it has nothing to do with the service whose registered trademark is ヨミヤス (YOMIYAS).

## Icons in sample documents

Icons placed in `docs/` follow their sets' licenses (Lucide: ISC; logos: CC0, the logos are their owners'
trademarks), recorded per document in `figures/icons/ICONS.md`.

## Build-time dependencies

daisyUI (MIT) and Tailwind CSS (MIT) are compiled into `skills/doc-kit/kit.css`. The file keeps Tailwind's notice
without its version number (the versions are in `package.json`), so that the file changes only when the CSS does.
