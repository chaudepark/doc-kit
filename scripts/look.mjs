#!/usr/bin/env node
// Pictures of a kit page as a reader sees it, at desktop and phone width.
//   node scripts/look.mjs <page.html> <out dir>      → <out dir>/<width>-<view>.png
// Views: everything on one page (#all), the same with every <details> open, the same as one column of prose
// (what a page from Markdown gets), the home, and each screen by itself (the one-screen-at-a-time mode).
// Two runs on the same machine give the same bytes for the same look, so comparing the two folders answers
// "does the page look the same after this change?" (the kit workflow asks it for every dependency update).
// What it does not see: hover and focus, what stays stuck while scrolling, other browsers than Chromium,
// fonts this machine does not have.
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { chromium } from 'playwright';

const [page, out] = process.argv.slice(2);
if (!page || !out) { console.error('usage: look.mjs <page.html> <out dir>'); process.exit(2); }
mkdirSync(out, { recursive: true });
const url = `file://${resolve(page)}`;
const browser = await chromium.launch();
for (const width of [1280, 390]) {
  const tab = await browser.newPage({ viewport: { width, height: 900 } });
  // a part that opens with a transition is shot where it ends, not somewhere on the way: wait for every
  // animation on the page (those of pseudo-elements too), then for the frame after it
  const settle = () => tab.evaluate(async () => {
    await Promise.allSettled(document.getAnimations().map((a) => a.finished));
    await new Promise((done) => requestAnimationFrame(() => requestAnimationFrame(done)));
  });
  const shot = async (name) => {
    await settle();
    writeFileSync(`${out}/${width}-${name}.png`, await tab.screenshot({ fullPage: true, animations: 'disabled' }));
  };
  await tab.goto(`${url}#all`);
  await shot('all');
  const screens = await tab.evaluate(() => [...document.querySelectorAll('.doc-home[id], .doc-view[id]')].map((e) => e.id));
  await tab.evaluate(() => document.querySelectorAll('details').forEach((d) => { d.open = true; }));
  await shot('all-open');
  await tab.evaluate(() => document.querySelector('main')?.classList.add('doc-prose'));
  await shot('all-prose');
  for (const id of screens) {
    await tab.goto(`${url}#${id}`);
    await tab.reload();
    await shot(`screen-${id}`);
  }
  await tab.close();
}
await browser.close();
