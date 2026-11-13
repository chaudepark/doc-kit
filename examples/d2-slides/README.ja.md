# d2-slides：動く見本

[English](README.md) | 日本語

`deck.md` は本物のスライドです。`d2-diagram` の検証の経過を 8 枚にまとめたもので、図はすべて ```d2 のブロックに書き、TALA が配置します。
`built/` は、ビルダーがそこから作ったものです。`d2` を入れなくても開けて、差分を見られるように、コミットしてあります。

```sh
pnpm deck:example        # = build-deck.mjs examples/d2-slides/deck.md --out examples/d2-slides/built
```

`built/index.html` を開きます。矢印キーとスペースで進み、`o` で一覧、`p` で印刷です。

`deck.md` を直したら、必ずこれを実行します。`tests/d2/d2-slides.test.mjs` が、コミット済みの文言の一覧（manifest）とスライドの構造を、作り直したものと比べます。
図のバイト単位の比較は、固定した版の `d2` が要るので、このテストには入っていません（取り込み元では CI のワークフローがしていました。このリポジトリには、そのワークフローはありません）。
元とずれたままコミットされたビルドは、ビルドが無いより悪いものです。

## このスライドにかけた検査

```sh
pnpm exec vlmkit check integrity examples/d2-slides/built/index.html
#   verdict: CLEAN — 1280x800 ink 82.0%, 768x900 44.0%, 375x700 27.9%

pnpm exec vlmkit check integrity examples/d2-slides/built/print.html --viewports 1280
#   verdict: CLEAN — 8 components, 96 text blocks

pnpm exec vlmkit check copy examples/d2-slides/built/print.html \
  --manifest examples/d2-slides/built/copy.txt --allow-invisible unknown
#   manifest: 26 lines, missing 0

pnpm exec vlmkit check a11y contrast examples/d2-slides/built/print.html
#   inspected 133 text-bearing element(s) — 0 contrast failure(s)
```

このうち 3 つは、最初は落ちました。直した所はビルダーに入っています。
1280px の枠をグリッドの中央に置いたら 375px 幅で何も描かれなかったこと、余白のある枠の中のパーセント指定の高さが、どのスライドでも 114px 切れたこと、中央寄せの 2 段組みが長い箇条書きの両端を切ったこと、の 3 つです。
それぞれの経過はスキルのファイルに書いてあります。

検査が本当に止めるかも、確かめられます。`copy.txt` にスライドが言っていない文を 1 行足すと `copy-missing` が出るはずで、`--stage-h` を 260px に縮めると `clipped-content` が出るはずです。どちらかが 0 で終わるなら、検査が壊れています。

## 文言の検査の「見えない（unknown）」を再現する

`--allow-invisible unknown` は飾りではありません。
このスライドの文言 26 行のうち 8 行は、スライドにはっきり出ているのに `copy-invisible (reason: unknown)` と報告されます。
ビルダーだけで再現できます。

````sh
cat > /tmp/probe/deck.md <<'EOF'
---
title: probe
---

## Split slide

- `d2 validate` reads **syntax**. The renderers draw whatever the file says.
- There is no `--expect`, no layout report, and no collision check.
- Worst: a reference to an id **not in scope creates a new shape**.

```d2
direction: right
a -> b
```
EOF
# → 3 invisible-only
````

同じ 3 行から装飾を外すと通ります。同じ装飾の付いた短い行も通ります。装飾の無い行の中に、装飾の付いた長い行が 1 つあるだけでも通ります。
つまり原因は、折り返しだけでも、装飾だけでも、2 段組みだけでもありません。
どの場合も `missing` の数は変わりません。だから、このスライドの手順は `missing` の数を読み、この種類の報告は受け入れています。

直すなら、スライドではなく文言の検査のほうです。いくつかのインライン要素から組み立てられた文が、「読み手に見えない文」と報告されるべきではありません。
