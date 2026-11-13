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
- Install hints say `pnpm add -D` for `npm i -D`.
- Not taken: its personas, evals, and the sample documents written for one named reader.

## first-reader (Apache-2.0)

`skills/first-reader/` is from Shubham Saboo and contributors' awesome-llm-apps, as bundled and changed by the
explainer project. Its `LICENSE` and `NOTICE` are in that directory.

## Icons in sample documents

Icons placed in `docs/` follow their sets' licenses (Lucide: ISC; logos: CC0, the logos are their owners'
trademarks), recorded per document in `figures/icons/ICONS.md`.

## Build-time dependencies

daisyUI (MIT) and Tailwind CSS (MIT) are compiled into `skills/doc-kit/kit.css`; the file keeps their notices.
