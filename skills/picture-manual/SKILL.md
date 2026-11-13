---
name: picture-manual
description: Turn the manual, README or cheat sheet of a tool (a device, a plug-in, a command, an app, a workflow) into a page a tired reader gets at a glance — each thing they want to do as a card with a picture of before and after, one line of how, one line of what comes out; the flow of use in a few pictures first; the specification folded away or left in the reference. The pictures are drawn from the tool's real output, not sketched. Use whenever the user says a manual or doc is hard to follow, too long, "結局なんだっけ", asks for 図解 or 絵で説明 of a tool, 早見表, チートシート, わかりやすいマニュアル, 使い方のページ, or wants the use of something they built shown simply (eli5 for their own tool) — even if they only say the doc "could be clearer". Not for explaining a concept, a PR, a design or a result to a reader, nor for a general topic with no tool behind it (the explainer skill does those), nor for API reference or a spec that must stay complete. The page's look is the doc-kit skill's, and the page is checked, looked at and read by simulated readers (the first-reader skill) before it is handed over, without the user asking.
---

# Picture manual

A manual fails its reader in a known way: it starts with terms, explains each setting in full, and by the third
paragraph the reader has lost the first ("結局なんだっけ？"). The reader did not come to learn the tool; they came with
something they want to do. So the page answers three things for each wish and nothing else:

**what I want → how I do it → what comes out**, with a picture that shows the third.

This is the eli5 idea (explain to someone who knows nothing, big pictures, few words) applied to a tool that exists:
because the tool exists, the pictures can be its real output, and the full text can stay behind the page as the
reference.

What this skill is not for: a concept, a PR, a design or a result explained to one reader, or a general topic
with no tool behind it. Those are the `explainer` skill's (prose for one reader, its claims verified by tools).
This skill is for how to use a thing.

## The shape of the page

1. **Opening: the flow of use in 3 to 5 pictures**, one line under each (do this → press that → compare → keep one).
   The long steps and the glossary come after it, folded (`<details>`), never before it: a definition means nothing
   until the reader has seen the thing it names.
2. **Wish cards** (about 7 to 12). Each card:
   - the heading is the wish in the reader's words (ベースを動かしたい, not "Bass motion");
   - one line of how: where (which track, screen, file), the setting, the value;
   - the picture: いま → こうなる, the same view on both sides;
   - one line of the result, something the picture visibly shows;
   - a link to the reference rows for that setting.
3. **The settings, value by value**, for looking things up: each value one line of what happens, with a picture
   wherever the value changes the output, and the values of one setting side by side so they can be compared.
4. No specification on the page. What the tool does not do, conditions, exceptions, the version a thing arrived in,
   how it is built: all true, all belonging to the reference. On this page they are the noise the reader complained
   of. Fold them behind a switch or leave them in the reference and link to it.

### When the tool has many settings: one screen at a time

Pictures for every value make a page of a large tool very long (a landing page that never ends), and the reader is
lost again, this time by scrolling. Then the cards become the home screen and each card opens its own screen: only
that wish's settings and pictures, with a way back. Keep it one file, the screens switched by the address's `#name`:
it still opens from `file://`, works offline and on a phone, the browser's Back works, and one test still covers it.
CSS alone does it, and the kit has it: the home is `doc-home`, each screen a `doc-view` with an `id`.

What the reader presses is what they arrive at: a card's heading is its screen's heading, word for word (`dockit
check` compares them). Use one vocabulary on the whole page, the wishes: cards, screens, chips and the band all in
the same words. A second set of names (the settings' groups: "Making from the input", "Sound") makes the reader
translate, and they lose where they are. Every setting lives on exactly one wish's screen; a setting no wish covers
gets a wish in the reader's words or joins the one it serves.

Give a way to show everything at once (an `#all` target, and print), for searching the page and for printing. On each
screen: a band stuck to the top with the way back and the screen's name, each setting's name stuck above its
pictures (so the reader always sees where they are), and the other screens' chips at the end, the current one marked.
The kit lets the page use the window and gives each picture a floor (`doc-vals`); the name stuck above is
`doc-sticky`. Keep the pictures out of table cells, which shrink them. Test that every
chip has its screen. Separate files only when the screens are built by different tools or the one file gets too
heavy to load.

While the user has the page open, rebuild it the moment the template or the generator is saved: a half-built page
(pictures in, their styles not yet) is what they will judge.

## Steps

These are one part of how this plugin makes any page (the doc-kit skill's SKILL.md, "Every page goes the same
way"). Read that file before the first card: the look, the check, the screenshots and the readers come with
this skill, and the user does not ask for them.

### 1. See the doc as its reader does

Render it and look at the screen, not the source (`scripts/shots.sh`, below). Ask the user which document they read
and where they stalled; a vague "なんとなくわかりにくい" is normal, so bring a diagnosis for them to react to:

- What comes first: the flow, or terms and a feature list?
- How many sentences before the first thing the reader can do?
- Is there any picture? Does each picture belong to a wish?
- How much of each explanation is specification (しない, のときだけ, v33 から)?
- Can it be looked up by wish, or only by the setting's name?

### 2. List the wishes

From the reader's side, in their words, one outcome each. Take them from what the user says they do with the tool,
from the settings grouped by purpose, and from the examples the doc already gives. For each, fix the smallest way to
get it: one setting, one value. A wish that needs three settings is two wishes or a flow picture.

### 3. Draw the pictures from the real thing

Run the tool itself on one small fixed input and draw what it returns, before and after the setting. A sketch drifts
from the tool and can show what the tool does not do; real output cannot, and it redraws itself when the tool changes.

- Use one input everywhere it serves (one chord progression, one sample file, one record), so the reader learns it
  once; add a second input only for wishes the first cannot show.
- Draw in the form the reader already knows from the tool (a piano roll for MIDI, a waveform, a table's rows, the
  terminal's lines, the panel's own layout) and in the tool's own colours.
- **Check each picture against its line at build time**: if the line says a note is added, assert the after has more
  notes; if it says the top voice stays, assert it. A card whose picture cannot show its line is a wrong card: change
  the example or the wording, do not ship it.
- When a picture does not show what its line says, look first for another setting that hides the effect (a mode that
  drops the candidates, a style in which the value does nothing): change the input or that setting, and say on the
  page what the picture was drawn with. Compare at the level the line speaks of (the chords' roots and kinds, not
  the voicing). A value that gives the same output as another gets no second picture: say "same as X".
- With many pictures, draw one round of the pattern, not the whole loop (two bars, not four), so the shapes stay
  readable when small; draw an odd meter in that meter and write it on the picture.
- When the tool's colours are near the kit's primary, look at the pictures' highlight on each of them and set
  `--doc-hi` to a colour that stands out (doc-kit's SKILL.md).
- Mark what changed when the two sides look alike at the size they are shown (another colour for the held note, the
  added chord's name in the accent colour).
- No real output to draw (a command with side effects, a setting of a GUI)? Use the next most real thing: its actual
  output text, a screenshot of the actual screen, a diagram built from the actual configuration. Say on the page what
  the picture is.

Inline SVG made at build time is the default: it is deterministic, testable, readable on a phone, needs no script.
Move to canvas or lazy drawing only when the number of pictures makes the page heavy.

### 4. Write the words

Each line answers one of the three questions and stops. Prefer the result the reader will see or hear over the
mechanism ("和音が変わる直前に、つなぎの音が1つ入る", not how the engine picks it). Keep one source for the words: when a
reference (README, spec) already says it, generate the page from the reference instead of writing a second copy, and
add the short line to the reference if it lacks one. Two copies drift; the reader then trusts neither.

### 5. Show a trial first

"Easy to understand" is the reader's judgment, and they often cannot say what they want until they see it. So make a
throwaway version of the top of the page on a copy (the opening and a few cards), show it, and change it by their
reaction, two or three rounds, before building it into the real generator. Tell them what is rough in the trial so
they judge the shape and not the roughness. Do not touch the real page until the shape is liked.

### 6. Build it in, and keep it true

Put the pictures and cards into whatever builds the real page, with a test that the committed page is the
generator's output, so the page cannot fall behind the tool. If the doc belongs to someone else's part of the project,
hand over the trial, the user's own words and the list of what the page should become, not only "make it clearer".

### 7. Look at the result

`scripts/shots.sh <page.html> <out dir>` writes desktop and phone-width screenshots (and `--theme light|dark` for a
page that switches by `data-theme` on `<html>`). Read the images. For every picture: can the difference be told at
this size? Is anything too small to read? Does the phone width break the cards? Three columns of small pictures on a
desktop often read worse than one column on a phone; give the pictures room.

A headless browser captures only the first screen of a page (a `#anchor` or a scroll does not move it): to see
further down, ask for a taller window (`--height`). A page opened with a `#name` that is longer than the window can
come out with an empty band above the target: the shot's doing, not the page's. What a shot cannot tell: whether
sticky headings stay while scrolling, and whether the links move; say so, or try them in a real browser.

### 8. Have it read

The `first-reader` skill reads the page before the user does; this is not something the user asks for. A
manual is reference material in its terms: nobody reads it in order, they come with a wish. So cast its
readers as people who use the tool, and give each a wish as a lookup task: some of the page's own wishes in
other words than the card's, and two or three the page does not name. A reader who cannot find their wish, or
finds it under a heading they would not have looked under, is a finding about the cards' words or the page's
shape: fix that (step 2 or the shape), not the sentence. (Whether a reader knows where they are on a screen is
seen in step 7's pictures, not in the text.) The text for the readers:
`python3 ../doc-kit/scripts/dockit text page.html > page.txt`. After fixing, build, check, and have the same
readers look once more. The trial of step 5 is not read by them: the user is its reader. When this step may be
left out, and what to say then, is in doc-kit's SKILL.md ("Every page goes the same way").

## A card, for the trial

The look is not this skill's: it comes from the doc-kit skill beside this one (`../doc-kit/`: `kit.css`, the parts
in `sample.html`, `scripts/dockit`). Read its SKILL.md before the first card. A card in its parts:

```html
<a class="card card-border bg-base-100" href="#bass"><div class="card-body">
  <h3 class="card-title">ベースを動かしたい</h3>
  <p class="doc-how"><span class="badge cont-bass">BASS</span>Bass を <code>approach</code> に</p>
  <div class="doc-ba"><div><span class="doc-note">いま</span><svg>…</svg></div>
    <span class="doc-to">→</span><div><span class="doc-note">こうなる</span><svg>…</svg></div></div>
  <p>和音が変わる直前に、つなぎの音が1つ入る。</p>
</div></a>
```

The page's own CSS holds only the tool's colours and how its pictures are painted (`cont-bass` above), every class
named with the tool's prefix: a picture's class called `input` or `btn` takes a kit part's styles.

## Telling the user

Give the page's path (a `file://` link), what changed in two or three lines, what the readers said and what you
changed for it, and what you did not check (a theme, a
width, a link). The user reads the page, not the report.
