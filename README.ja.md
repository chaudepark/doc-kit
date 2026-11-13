# doc-kit

[English](README.md) | 日本語

AI が人間に向けて書く文書を、**読める形**と**同じ見た目**で出すための、スキルと道具です。

コーディングエージェントは、マニュアルも説明もいくらでも書きます。困るのは、長くて読めないことと、書くたびに見た目が違うことです。
このリポジトリは、Claude がその場で見た目を考えるのをやめさせます。ページは決まった部品だけで組み、スクリプトで確かめてから渡します。

使うのは基本的に Claude です。人間がすることは、入れることと、頼むことと、できたページを読むことです。

## インストール

Claude Code のプラグインです。このリポジトリがそのままマーケットプレイスで、プラグイン `doc-kit` にスキルが 7 つ入っています。

```sh
claude plugin marketplace add chaudepark/doc-kit
claude plugin install doc-kit@doc-kit
```

Claude Code の中からは `/plugin marketplace add chaudepark/doc-kit` と `/plugin install doc-kit@doc-kit` です。
更新は `claude plugin marketplace update doc-kit` のあとに `claude plugin update doc-kit@doc-kit` です。入れたあと、動いているセッションは起動し直します。

| スキル | 頼み方の例 | Claude がすること |
|---|---|---|
| `doc-kit` | 「HTML でまとめて」「見た目を揃えて」 | 見本にある部品だけでページを組み、`dockit` で確かめる。ほかのスキルの見た目もこれ |
| `picture-manual` | 「このマニュアル、わかりにくい」「早見表にして」 | 道具の説明を「やりたいこと → どうやる → どうなる」のカードにする。絵は道具の本物の出力から描く |
| `explainer` | 「この PR を私がわかるように説明して」 | 読み手 1 人のペルソナを作り、その人が知らないことだけを書く。引用した出力と図は道具で検証する |
| `explainer-book` | 「章立ての学習資料にして」 | 学習目標・概念の順序・読了時間・演習を検査した、章立ての資料 |
| `first-reader` | 「公開前に読んでみて」 | 模擬読者に 1 段落ずつ読ませ、どこで離脱し、翌日何が残るかを報告する。書き直しはしない |
| `d2-diagram` | 「アーキテクチャ図を D2 で」 | TALA で配置した D2 の図を、事実シートと突き合わせる |
| `d2-slides` | 「スライドにして」 | Markdown 1 枚から、図入りの HTML スライドを作って検査する |

ほかのプロジェクトから取り込んだものは [NOTICE.md](NOTICE.md) に書いてあります。`explainer` と `explainer-book` のファイルは日本語で書かれていますが、資料は読み手の言語で書きます。

## 何をするか

```
頼む ─→ スキルが手順を決める ─→ 本文（部品だけ） ─→ 1 ファイルの HTML ─→ 検査 ─→ 目で見る
          │                        │                   │                  │
     picture-manual           見本にある部品        kit.css を埋め込む   dockit check
     explainer ほか           （sample.html）       ダークのみ           画面を撮って確かめる
```

- **見た目は 1 つ**：`skills/doc-kit/kit.css`（daisyUI 5 と Tailwind CSS 4 から作り済み）。フォント、文字の大きさ（5 種類）、幅、色はここだけで決まります。ページはダークだけです。
- **部品は見本にあるものだけ**：`skills/doc-kit/sample.html` が、使ってよい部品の一覧です。ビルドに残るのは見本が使うクラスだけなので、見本に無いものはページで効きません。
- **検査**：`dockit check` が、見本に無いクラス、古い `kit.css`、部品と同じ名前の絵のクラス、カードと着いた画面で違う見出し、外部の読み込みを止めます。
- **1 ファイル**：できたページは、オフラインでもスマホでも開けます。使う側のリポジトリに Node もビルドも要りません（`dockit` は Python 3.9 の標準ライブラリだけ）。
- **言語を問わない**：ページの言語は本文から決まります（かながあれば日本語、なければ英語）。`--lang` でも指定できます。フォントは、Mac・Windows・Linux に元からある欧文と日本語の書体です。

部品を足すのは、ページの上ではなく、このリポジトリの見本です。足す前に、持ち主に聞く決まりにしています（部品が少ないことが目的なので）。

## ページの 2 つの形

| 形 | 向いているもの | 作り方 |
|---|---|---|
| 広いページ（カードと絵） | マニュアル、早見表。画面を 1 つずつ出す | 本文を書いて `dockit wrap` |
| 本文のページ（1 段組） | 説明、報告、本の章。Markdown から | `explainer` の `build-html.mjs`、または `dockit wrap --prose` |

```sh
python3 skills/doc-kit/scripts/dockit wrap body.html -o page.html --title "題名" [--css own.css] [--prose] [--lang ja]
python3 skills/doc-kit/scripts/dockit check page.html
node skills/explainer/scripts/build-html.mjs docs/<topic>/README.md     # → docs/<topic>/dist/index.html
```

ページが自分で持ってよい CSS は、その道具の色と、絵の塗り方だけです（クラス名には道具の接頭辞を付けます）。

## explainer の依存

`explainer` のスクリプトは、資料を置くリポジトリの `node_modules` を使います（Node 24 以上）。

```sh
pnpm add -D marked @mizchi/vlmkit playwright mermaid
```

D2 の図には `d2` の CLI、データの図には `vega` と `vega-lite`、アイコンには `@iconify-json/lucide` と `@iconify-json/logos` が要ります。HTML にするだけなら `marked` だけで足ります。

## このリポジトリを直す

```sh
pnpm install
pnpm build          # src/ から skills/doc-kit/kit.css と sample.html を作り直す
pnpm test           # 作り済みのファイルが src と合っているか、check が効くか、explainer が kit のページを出すか、ブラウザの要らない取り込みテスト
pnpm exec playwright install chromium && sh scripts/setup-d2.sh   # 次の行のために、初回だけ
pnpm test:figures   # figure-check の回帰テスト（ブラウザと d2 を使う）
```

テーマと色は `src/kit.css` の `@plugin "daisyui"` の行、部品は `src/kit.css` の `doc-` のクラスと `src/sample.html` です。`skills/doc-kit/kit.css` は手で直しません。

既知の点：`figure-check` は、Mermaid の図をコミット済みの SVG とバイト単位で比べます。Mermaid は文字の配置にその機械のフォントを使うので、ある OS で描いた図は、別の OS では「古い」と判定されます。その機械で `--write` を付けて描き直してください。

## 構成

| パス | 内容 |
|---|---|
| `src/kit.css`, `src/sample.html` | 見た目の元。Tailwind と daisyUI の入口、`doc-` の部品、見本の本文（`src/classes.txt` は見本から作る） |
| `skills/doc-kit/` | 見た目のスキル。作り済みの `kit.css` と `sample.html`、`scripts/dockit`（wrap / check） |
| `skills/picture-manual/` | 絵で説明するマニュアル。`scripts/shots.sh` はページの撮影（パソコン幅とスマホ幅） |
| `skills/explainer/`, `skills/explainer-book/` | 読み手 1 人に向けた説明と本。`scripts/build-html.mjs` が kit のページを出す |
| `skills/first-reader/` | 模擬読者（Apache-2.0） |
| `skills/d2-diagram/`, `skills/d2-slides/` | D2 の図とスライド |
| `docs/`, `examples/` | 見本の資料（図の道具の使い分け、データの図）と、見本のスライド |
| `tests/` | `test.sh`（全体）と、取り込んだスキルのテスト（`d2/`、`figure-check/`、`first-reader/`） |
| `scripts/` | `build-kit.sh` と、`setup-d2.sh`・`setup-tla.sh`（道具を `.tools/` に取得する） |
| `.claude-plugin/` | プラグインとマーケットプレイスの定義 |

## ライセンス

[MIT](LICENSE)。
ほかのプロジェクトから取り込んだものは、元のライセンスに従います。大部分は MIT（`LICENSES/explainer-MIT.txt`）、`skills/first-reader/` は Apache-2.0（同じディレクトリの `LICENSE` と `NOTICE`）です。内訳は [NOTICE.md](NOTICE.md) にあります。
