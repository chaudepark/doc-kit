// figure-check.mjs の回帰テスト：悪い図はそれぞれの検査で落ち、良い図は通る
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { cpSync, mkdtempSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
const here = dirname(fileURLToPath(import.meta.url));
const tool = join(here, '../../skills/explainer/scripts/figure-check.mjs');
const cases = [
  ['good.svg', null],
  ['line-through.svg', /a line runs through/],
  ['crosses-edge.svg', /cross a box edge/],
  ['overlap.svg', /text overlap/],
  ['clipped.svg', /outside the figure/],
  ['nested-edges.d2', null],
  ['wrong-edges.d2', /edges differ/],
  ['mermaid-good.mmd', null],
  ['mermaid-edges.mmd', /edges differ/],
  ['arrows-shared.d2', /重なって走る/],
  ['arrows-through.svg', /の中を通る/],
  ['icon-good.d2', null],
  ['icon-unrecorded.d2', /no source \/ license/],
  ['icon-missing.d2', /render failed|not embedded/],
  ['chart-good.vl.json', null],
  ['tofu.svg', /no glyph/],
  ['outlined.svg', /drawn as outlines/],
];
let bad = 0;
for (const [file, want] of cases) {
  // Mermaid lays a figure out with the machine's font metrics, so a committed SVG is byte-equal only where it was
  // rendered (on another OS it reads as stale). The .mmd cases run on a copy and render afresh: the checks are
  // what is tested, not the bytes.
  let target = join(here, 'fixtures', file), extra = [];
  if (file.endsWith('.mmd')) {
    const dir = mkdtempSync(join(tmpdir(), 'figure-check-'));
    const stem = file.replace(/\.mmd$/, '');
    for (const f of readdirSync(join(here, 'fixtures'))) if (f.startsWith(`${stem}.`)) cpSync(join(here, 'fixtures', f), join(dir, f));
    target = join(dir, file); extra = ['--write'];
  }
  const r = spawnSync('node', [tool, target, '--out', join(here, '.out', file), ...extra], { encoding: 'utf8' });
  const out = r.stdout + r.stderr;
  const fails = out.split('\n').filter((l) => l.includes('✗'));
  const pass = want ? fails.some((l) => want.test(l)) : r.status === 0;
  if (!pass) bad++;
  console.log(`${pass ? 'ok ' : 'NG '} ${file}: ${want ? `expected ✗ ${want}` : 'expected CLEAN'}${pass ? '' : `\n    got: ${fails.join(' | ') || 'CLEAN'}`}`);
}
console.log(bad ? `${bad} FAILED` : 'figure-check tests passed');
process.exit(bad ? 1 : 0);
