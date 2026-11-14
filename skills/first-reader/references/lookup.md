# A read by lookup

For a page nobody reads in order: a manual, a cheat sheet, a reference in screens or sections. Its readers
come with something they want to do, look for it, and leave. This file is the whole procedure for such a
page. Nothing else in SKILL.md is needed for it: no timed read, no recall test, no trust ledger, no
manifest, no page of the read. It was worked out on a real manual.

Added by the doc-kit project; not part of the upstream skill.

There is one way through it. Nothing below is a level or an option: every such page gets the words read
and the pictures read, in this order.

## What you need

- **The page's text, in the steps a reader meets it.**
  `python3 <doc-kit>/scripts/dockit lookup page.html -o <run dir>` (`<doc-kit>` is the doc-kit skill's
  directory, beside this skill's). It writes `home.txt` (the page before anything is pressed), for each
  screen `abstract-<name>.txt` (what the screen says before its detail begins) and `screen-<name>.txt`
  (all of it), one `fold-<n>.txt` for what each folded part holds, and `index.txt` (what opens which file:
  a card, a folded part, a link on the home; for you, not for the readers). Its last line, `mark …`, is
  a mark of the page's words and pictures: write it in the readers file. A page whose mark is that of its
  last read says and shows the same, and is not read again. It works on any HTML page: one that is not in screens is cut at its
  `<h2>` headings.
- **The page's pictures, each alone.**
  `python3 <doc-kit>/scripts/dockit pictures page.html -o <run dir>/pictures` (it needs a Chromium-family
  browser, the one the screenshots are taken with). It writes `quiz-<n>/quiz.md` with its
  `pic-<number>.png` files (twenty pictures a quiz at most, four quizzes at least, so that a reader is
  never shown the neighbours whose lines it is offered), `key.tsv`, which is for `dockit grade` and not
  for a reader, and `unasked.txt`, the pictures it could not ask about.
- **`<page>.readers.md`, committed, beside what a person edits to change the page** (its README, its
  template, its generator; not beside a built page that git ignores): the reader, the wishes, each
  round's result (the form is at the end). Writing the reader and the wishes is the costly part, and it
  is done once: the next read of the page is two commands and a few subagents. The run directory
  (`.first-reader/<page>-<date>/` beside that file, `-r2` for a second run that day) holds only what a
  run made and can be thrown away.

In the text the readers get: `[picture: its label]` is a picture they cannot see here (a bare `[picture]`
has no label on the page, which is worth a line in your findings); `[folded]` is a part that opens when
pressed; `[opens a screen]` after a heading is a card that can be pressed; `[word]` is a badge; a line
with `|` is a table's row; `- ` lines in a group are links.

You have seen the page (you made it, or looked at its pictures): that is fine. The readers have not. Each
reader is a fresh subagent, and "the same reader again" is a new subagent given the same persona. A small,
fast model reads well enough.

## The reader

One person: the page's owner a month later. They know the field and the equipment and have forgotten this
tool's names. Write them for this page's real user, in two lines.

Two fresh subagents read as this person, each alone. They are not two kinds of reader: a read is one
sample, and two say more than one. Whether the reader is tired or has time is not a fork here. A page that
serves the one in a hurry is a page whose screens answer in their abstract, and that is what the read
below tests for every reader.

## The wishes

Eight to ten, in the reader's words and never in the page's headings: a wish that repeats a heading finds
it, and proves nothing. Two or three are wishes the page does not name, and one of those is something the
tool cannot do. That one tests whether "it cannot" has a place on the page, or leaves the reader not
knowing whether it is absent or they missed it. Take "cannot" from a sentence in the tool's reference and
quote it in the readers file; if the reference does not say, you have found a "no fact" before any reader
has read.

## The read of the words

Each reader, alone. Before step 1, tell them what the marks in the text mean (above).

1. The reader gets `home.txt` and the wishes, and writes for every wish what they would press (a card
   marked `[opens a screen]`, or a `[folded]` part) and how sure they are: sure, probably, or guessing.
   "Nothing here; I would give up" is an answer too. All wishes before step 2, and no changing afterwards.
2. For each wish the reader gets the **abstract** of the screen they pressed (`abstract-<name>.txt`; for a
   folded part, its `fold-<n>.txt`) and nothing else, and says what they would do, or that the abstract
   does not say.
3. Only for a wish the abstract did not answer, the reader gets the whole screen (`screen-<name>.txt`),
   says what they would do, and where they stopped. If that does not answer it either, they may name one
   more press from what they now see (a folded part, a link at the end of the screen); give them that
   text too, and stop there.

`index.txt` says which file a press opens. Give a reader the file's text in the message; never the run
directory, which holds every screen. One reader is one subagent over the three steps (continue it from
step to step). Ask each for a report in this order: for every wish, what they would do and from which
step; every stumble, with the page's own words quoted; then, without looking back, what they remember;
then one question for the author. (That question tends to point at the page's largest hole.)

What a reader in a hurry gets is not asked of the reader: it is what step 2 hands them. `dockit check`
holds every screen to having an abstract that says something and is short; whether it answers the
screen's wish is what this read finds out.

## Reading the result

For each wish, you decide, against the tool's reference (the readers do not know the tool):

- **from the abstract**: pressed the right place, and what they would do is right, from step 2. For a wish
  the tool cannot fulfil: they say it cannot be done, and quote the page saying so.
- **from the screen**: right, but only in step 3, or after a wrong first press. When the wish is the
  screen's own wish, this is a finding: the abstract does not carry the answer. When the wish is about one
  of the screen's details (which value, an exception), the detail is where it belongs.
- **not found**: gave up, or ended somewhere else, or would do the wrong thing. Sure and wrong is the worst
  kind: note it.

Then sort every stumble:

- **words**: the page says it, under words the reader did not look for. Change the card's, the heading's or
  the abstract's words; the wish is how a reader says it.
- **no place**: it is true and the page does not say it. Give it a place: a card, a line, or "this cannot
  be done, and what to do instead".
- **no fact**: nobody has tried it or measured it. This is not fixed by rewriting: it becomes an issue, or
  a line in the hand-over. Do not cover it with wording.

A note that admits something on the page is not real ("this number is not from a real recording") makes a
reader doubt the whole procedure. Say first which parts are real, then what is not.

## The read of the pictures

The readers of the words do not see pictures, and on such a page the pictures are the point. So the
pictures are read too, one at a time: a reader is shown a picture without its neighbours, and says which
line is its own.

1. One fresh subagent for each `quiz-<n>` directory. It gets that directory and nothing else, follows
   `quiz.md` (for each picture: open the file, choose among up to four lines the one that is this
   picture's, say in a few words what it sees) and writes `answers.txt` there.
2. `python3 <doc-kit>/scripts/dockit grade <run dir>/pictures` names every picture that was not read as
   what it is: its file, the line it is held to, the line it was read as, and what the reader saw.

A picture's line is its caption, else its own label, else its card's title, else the heading it stands
under; the other lines are its nearest neighbours' (the other values of the same setting first). A miss
means the picture does not say its line, or cannot be told from its neighbour. Look at the picture file:
when the line is true of the tool, redraw the picture so that the difference shows; when the picture is
what the tool does, the line is wrong, so change the line. `unasked.txt` lists the pictures that were not
asked about (no words of their own, or no neighbour with other words): give each a label. An icon in a
button, a badge, a key or a heading is not a picture, and a `<canvas>` is not read.

## The second round, and the end

After the fixes: the same wishes, the same persona, new subagents; `dockit pictures` and its readers
again. Mark the wishes whose heading or abstract the fix moved towards the wish's own words; a hit there
was bought, not found. One second round, no third: what still stumbles goes in the hand-over.

## Limits, to say in the hand-over

- The page, the wishes and the verdicts on the words come from the same kind of model, and a read is one
  sample: run again, a reader can press differently. What the readers found is real (hold it against the
  page); what they did not find proves nothing. No person has been compared with these readers.
- A picture's reader chooses among four lines or fewer, so one right choice in four (or more) is right by chance: a
  miss is a finding, a hit is not proof. The reader is a model looking at an image file, at phone width;
  whether a person sees the same at a glance has not been measured.

## `<page>.readers.md`

```markdown
# <page>, read by lookup

- **Reader**: <the owner a month later, in two lines>

Wishes (in the reader's words; * = the page does not name it; ✗ = the tool cannot do it):

A. …
B. …
H.* …
J.*✗ … (cannot: "<the reference's sentence>")

Round 1 (<date>, the page's source at <commit>, mark <the mark dockit lookup printed>)
Words: from the abstract: A, C, E. From the screen: B, D. Not found: J.
Stumbles: <words / no place / no fact, one line each, with the page's words quoted>
The readers' questions: 1: … 2: …
Pictures: <how many> read, <how many> not read as what they are: <number: is / read as, one line each>

Round 2 (<date>, the page's source at <commit>, mark <mark>; moved towards the wish: D)
Words: from the abstract: … From the screen: … Not found: …
Pictures: …
Left for the hand-over: …
```
