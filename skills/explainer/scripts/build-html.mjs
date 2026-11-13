#!/usr/bin/env node
// Markdown を自己完結 HTML にする。1 ページでも、章立ての本でも。
// - figures/*.svg への画像リンクは SVG をそのまま埋め込む (外部参照なし)
// - figures/*.fig.png への画像リンクは、同名の *.fig.html（手で書いた HTML の図）があればそれを埋め込む
// - 複数ページのときは、ページ間の .md リンクを .html に張り替え、目次・前後の章へのナビを付ける
//
//   node build-html.mjs <doc>/README.md                       → dist/index.html
//   node build-html.mjs <book>/README.md <book>/01-x.md …     → dist/index.html, dist/01-x.html, …
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { basename, dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

// 依存は「資料を置いたリポジトリ」の node_modules から解決する。
// プラグインとして入れたとき、このスクリプトの隣には node_modules が無いため。
const projectRequire = createRequire(join(process.cwd(), 'package.json'));
let marked;
try {
  ({ marked } = await import(pathToFileURL(projectRequire.resolve('marked')).href));
} catch {
  console.error('marked is not installed in this project: pnpm add -D marked @mizchi/vlmkit playwright');
  process.exit(2);
}

const pages = (process.argv.length > 2 ? process.argv.slice(2) : ['README.md']).map((p) => resolve(p));
const docDir = dirname(pages[0]);
const dist = join(docDir, 'dist');
mkdirSync(dist, { recursive: true });

const htmlName = (md) => (basename(md) === 'README.md' ? 'index.html' : basename(md).replace(/\.md$/, '.html'));
const titleOf = (src) => src.match(/^# (.+)$/m)?.[1] ?? 'Explainer';
const sources = pages.map((p) => readFileSync(p, 'utf8'));
const book = pages.length > 1;
// the page's language, read from its prose: kana means Japanese, anything else is set as English.
// Code is not prose: an English page that quotes a tool's Japanese output stays English.
const ja = (src) => /[\u3040-\u30ff]/.test(src
  .replace(/^ {0,3}(`{3,}|~{3,})[^\n]*\n[\s\S]*?^ {0,3}\1[`~]*[ \t]*$/gm, '') // a fence opens and closes at a line's start
  .replace(/`[^`\n]*`/g, ''));
const mdNames = new Set(pages.map((p) => basename(p)));

function render(src) {
  let md = src.replace(/<!--[\s\S]*?-->/g, '');
  // 図のマークアップは Markdown に通さない。空行や字下げがあると、marked が HTML ブロックを閉じて
  // 残りを <pre> にしてしまうため（D2 の SVG で起きた）。置き換え用の印を置き、変換のあとで戻す
  const figures = [];
  const hold = (html) => `\n\nXFIGUREX${figures.push(html) - 1}XFIGUREX\n\n`;
  // HTML の図：Markdown は figures/<name>.fig.png を参照し、HTML では figures/<name>.fig.html をそのまま埋め込む
  md = md.replace(/!\[([^\]]*)\]\((figures\/[^)]+?)\.fig\.png\)/g, (all, alt, base) => {
    const html = join(docDir, `${base}.fig.html`);
    if (!existsSync(html)) return all;
    return hold(`<figure class="doc-fig" aria-label="${alt}">${readFileSync(html, 'utf8')}<figcaption>${alt}</figcaption></figure>`);
  });
  // SVG の図 → インライン SVG
  md = md.replace(/!\[([^\]]*)\]\((figures\/[^)]+?)\.svg\)/g, (_, alt, base) => {
    const svg = readFileSync(join(docDir, `${base}.svg`), 'utf8').replace(/<\?xml[^>]*>/, '');
    return hold(`<figure class="doc-fig" role="img" aria-label="${alt}">${svg}<figcaption>${alt}</figcaption></figure>`);
  });
  // 画像（PNG など）の図 → data: URI で埋め込む（出力の HTML 1 枚で完結させる。dist には figures/ を写さない）
  const mime = { png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', gif: 'image/gif', webp: 'image/webp' };
  md = md.replace(/!\[([^\]]*)\]\((figures\/[^)]+?\.(png|jpe?g|gif|webp))\)/g, (all, alt, file, ext) => {
    const path = join(docDir, file);
    if (!existsSync(path)) return all;
    return hold(`<figure class="doc-fig"><img src="data:${mime[ext]};base64,${readFileSync(path).toString('base64')}" alt="${alt}"><figcaption>${alt}</figcaption></figure>`);
  });
  // 本の中のページへのリンクを .html に
  md = md.replace(/\]\(([\w.-]+\.md)(#[^)]*)?\)/g, (all, file, hash = '') =>
    // a page that is not built with this one (the other language's README) is beside the source, one level up from dist/
    // shortcut: read from the raw Markdown, so a link quoted inside code is rewritten too; parse with marked if that bites
    mdNames.has(file) ? `](${htmlName(file)}${hash})` : `](../${file}${hash})`);
  // the kit's parts for what Markdown gives bare: a table scrolls sideways in its own box; a code block's language class is dropped
  const html = marked.parse(md)
    .replaceAll('<table>', '<div class="overflow-x-auto"><table class="table">').replaceAll('</table>', '</table></div>')
    .replace(/<code class="language-[^"]*">/g, '<code>');
  return html.replace(/<p>XFIGUREX(\d+)XFIGUREX<\/p>|XFIGUREX(\d+)XFIGUREX/g, (_, a, b) => figures[Number(a ?? b)]);
}

function nav(i) {
  if (!book) return '';
  const link = (j, label) => `<a href="${htmlName(pages[j])}">${label}${titleOf(sources[j])}</a>`;
  const prev = i > 0 ? link(i - 1, '← ') : '<span></span>';
  const next = i < pages.length - 1 ? link(i + 1, '→ ') : '<span></span>';
  const toc = i > 0 ? `<a href="index.html">${ja(sources[i]) ? '目次' : 'Contents'}</a>` : '';
  return `<nav class="doc-book" aria-label="${ja(sources[i]) ? '章の移動' : 'Chapters'}">${prev}${toc}${next}</nav>`;
}

// The look is doc-kit's (the skill beside this one): its kit.css inlined, the body in <main class="doc doc-prose">.
// No CSS of this script's own: a part that is missing goes into the kit, not here.
const KIT = readFileSync(new URL('../../doc-kit/kit.css', import.meta.url), 'utf8').trim();

pages.forEach((p, i) => {
  const title = titleOf(sources[i]);
  const html = `<!doctype html>
<html lang="${ja(sources[i]) ? 'ja' : 'en'}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<style data-doc-kit>${KIT}</style>
</head>
<body><main class="doc doc-prose" id="all">
${nav(i)}
${render(sources[i])}
${nav(i)}
</main></body>
</html>
`;
  writeFileSync(join(dist, htmlName(p)), html);
  console.log(`wrote ${join(dist, htmlName(p))}`);
});
