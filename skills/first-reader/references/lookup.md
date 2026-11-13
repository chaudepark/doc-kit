# A read by lookup

For a page nobody reads in order: a manual, a cheat sheet, a reference in screens or sections. Its readers
come with something they want to do, look for it, and leave. This file is the whole procedure for such a
page. Nothing else in SKILL.md is needed for it: no timed read, no recall test, no trust ledger, no
manifest, no page of the read. It was worked out on a real manual (two readers, ten wishes, two rounds).

Added by the doc-kit project; not part of the upstream skill.

## What you need

- **The page's text, in the two steps a reader meets it.**
  `python3 <doc-kit>/scripts/dockit lookup page.html -o <run dir>` (`<doc-kit>` is the doc-kit skill's
  directory, beside this skill's). It writes `home.txt` (the page before anything is pressed), one
  `screen-<name>.txt` for each screen, one `fold-<n>.txt` for what each folded part holds, and `index.txt`
  (what opens which file; for you, not for the readers). It works on any HTML page: one that is not in
  screens is cut at its `<h2>` headings.
- **`<page>.readers.md`, committed, beside what a person edits to change the page** (its README, its
  template, its generator; not beside a built page that git ignores): the two readers, the wishes, each
  round's result (the form is at the end). Writing the readers and the wishes is the costly part, and it
  is done once: the next read of the page is one command and two subagents. The run directory
  (`.first-reader/<page>-<date>/` beside that file, `-r2` for a second run that day) holds only what a
  run made and can be thrown away.

In the text the readers get: `[picture: its label]` is a picture they cannot see (a bare `[picture]` has
no label on the page, which is worth a line in your findings); `[folded]` is a part that opens when
pressed; `[opens a screen]` after a heading is a card that can be pressed; `[word]` is a badge; a line
with `|` is a table's row; `- ` lines in a group are links.

You have seen the page (you made it, or looked at its pictures): that is fine. The readers have not. Each
reader is a fresh subagent, and "the same reader again" is a new subagent given the same persona. A small,
fast model reads well enough.

## The readers

Two, the same person at two moments:

- **the owner a month later**: time to spare, knows the field and the equipment, has forgotten this tool's
  names;
- **the same person in the middle of work**: tired, an idea fading, thirty seconds a lookup. Reads the
  first third of a screen with care and skims the rest; gives up when the first press is wrong and the
  second is not obvious.

Write them for this page's real user, two lines each.

## The wishes

Eight to ten, in the reader's words and never in the page's headings: a wish that repeats a heading finds
it, and proves nothing. Two or three are wishes the page does not name, and one of those is something the
tool cannot do. That one tests whether "it cannot" has a place on the page, or leaves the reader not
knowing whether it is absent or they missed it. Take "cannot" from a sentence in the tool's reference and
quote it in the readers file; if the reference does not say, you have found a "no fact" before any reader
has read.

## The read

Each reader, alone. Before step 1, tell them what the marks in the text mean (above), and that they cannot
see pictures.

1. The reader gets `home.txt` and the wishes, and writes for every wish what they would press (a card
   marked `[opens a screen]`, or a `[folded]` part) and how sure they are: sure, probably, or guessing.
   "Nothing here; I would give up" is an answer too. All wishes before step 2, and no changing afterwards.
2. For each wish the reader gets the text of what they pressed and nothing else, and says what they would
   do, and where they stopped. `index.txt` says which file that is. Give them the file's text in the
   message, or copies in a directory of their own; never the run directory, which holds every screen.
   If the first press does not answer the wish, the reader may name one more press from what they now see
   (a folded part, a link at the end of the screen); give them that text too. The tired reader stops
   there.

One reader is one subagent over both steps: continue it for step 2, or give a new one its own step-1
answers. Ask each for a report in this order: for every wish, what they would do; every stumble, with the
page's own words quoted; then, without looking back, what they remember; then one question for the
author. (That question tends to point at the page's largest hole.)

A limit to know: a model reads every line it is given. The tired reader's thirty seconds and "the first
third of a screen" are asked of it, not enforced; when an answer sat deep in a long screen, ask that
reader whether a tired person would have got that far, and count it as hesitation if not.

## Reading the result

For each wish, you decide, against the tool's reference (the readers do not know the tool):

- **sure**: pressed the right place, sure of it, and what they would do is right. For a wish the tool
  cannot fulfil: they say it cannot be done, and quote the page saying so.
- **hesitated**: got there with a wrong first press, or unsure, or with an answer that is partly right.
- **not found**: gave up, or ended somewhere else, or would do the wrong thing. Sure and wrong is the worst
  kind: note it.

Then sort every stumble:

- **words**: the page says it, under words the reader did not look for. Change the card's or the heading's
  words; the wish is how a reader says it.
- **no place**: it is true and the page does not say it. Give it a place: a card, a line, or "this cannot
  be done, and what to do instead".
- **no fact**: nobody has tried it or measured it. This is not fixed by rewriting: it becomes an issue, or
  a line in the hand-over. Do not cover it with wording.

Before counting a stumble, hold it against the page's pictures (open the page, or the screenshots taken
before this read). A reader who could not know what only a picture shows has found nothing, unless that
fact should be in words too.

A note that admits something on the page is not real ("this number is not from a real recording") makes a
reader doubt the whole procedure. Say first which parts are real, then what is not.

## The second round, and the end

After the fixes: the same wishes, the same two personas, new subagents. Mark the wishes whose heading the
fix moved towards the wish's own words; a hit there was bought, not found. One second round, no third:
what still stumbles goes in the hand-over.

## `<page>.readers.md`

```markdown
# <page>, read by lookup

- **S**: <the owner a month later, in two lines>
- **K**: <the same person in the middle of work, in two lines>

Wishes (in the reader's words; * = the page does not name it; ✗ = the tool cannot do it):

A. …
B. …
H.* …
J.*✗ … (cannot: "<the reference's sentence>")

Round 1 (<date>, the page's source at <commit>): sure: A, C, E. Hesitated: B, D. Not found: J.
Stumbles: <words / no place / no fact, one line each, with the page's words quoted>
The readers' questions: S: … K: …

Round 2 (<date>, the page's source at <commit>; heading moved towards the wish: D): sure: … Hesitated: … Not found: …
Left for the hand-over: …
```
