# doc-kit

[English](README.md) | 日本語

AI が人間に向けて書く文書を、**読める形**と**同じ見た目**で出すための、スキルと道具です。

コーディングエージェントは、マニュアルも説明もいくらでも書きます。困るのは、長くて読めないことと、書くたびに見た目が違うことです。
このリポジトリは、Claude がその場で見た目を考えるのをやめさせます。ページは決まった部品だけで組み、スクリプトで確かめてから渡します。

使うのは基本的に Claude です。人間がすることは、入れることと、頼むことと、できたページを読むことです。

**何も考えずに、誰でも使える。** これがこのリポジトリの目標です。ほかのプロジェクトのスキルを集めているのも、このためです。マニュアルは、いつでも、この道具で届くいちばん良い状態で出てきます。フラグやモードで出来が変わることはありません。使う人にも Claude にも、コマンドの使い分けは求めません（選ばせること自体が、選ぶ側の負担になるためです）。ページによって変わること（言語、形）は、スクリプトか決まった規則が決めます。

## インストール

Claude Code のプラグインです。このリポジトリがそのままマーケットプレイスで、プラグイン `doc-kit` にスキルが 8 つ入っています。

```sh
claude plugin marketplace add chaudepark/doc-kit
claude plugin install doc-kit@doc-kit
```

Claude Code の中からは `/plugin marketplace add chaudepark/doc-kit` と `/plugin install doc-kit@doc-kit` です。
更新は `claude plugin marketplace update doc-kit` のあとに `claude plugin update doc-kit@doc-kit` です。入れたあと、動いているセッションは起動し直します。

スキルの名前もフラグも言う必要はありません。やりたいことを言えば、スキル同士が呼び合います。どのページも、スクリプトで検査し、画面を撮って確かめ、模擬読者に読ませてから渡します。このうち、スクリプトが止めるものと、Claude に頼んでいるだけのものの区別は「[守られること、守られないこと](#守られること守られないこと)」に書きました。

| スキル | 頼み方の例 | Claude がすること |
|---|---|---|
| `doc-kit` | 「HTML でまとめて」「見た目を揃えて」 | 見本にある部品だけでページを組み、`dockit` で確かめる。ほかのスキルが作るページの見た目もこれ（`d2-slides` のスライドと、`first-reader` が作る読みの記録のページは別） |
| `picture-manual` | 「このマニュアル、わかりにくい」「早見表にして」 | 道具の説明を「やりたいこと → どうやる → どうなる」のカードにする。絵は道具の本物の出力から描く |
| `explainer` | 「この PR を私がわかるように説明して」 | 読み手 1 人のペルソナを作り、その人が知らないことだけを書く。引用した出力と図は道具で検証する |
| `explainer-book` | 「章立ての学習資料にして」 | 学習目標・概念の順序・読了時間・演習を検査した、章立ての資料 |
| `first-reader` | 「公開前に読んでみて」 | 模擬読者に 1 段落ずつ読ませ、どこで離脱し、翌日何が残るかを報告する。書き直しはしない |
| `d2-diagram` | 「アーキテクチャ図を D2 で」 | TALA で配置した D2 の図を、事実シートと突き合わせる |
| `d2-slides` | 「スライドにして」 | Markdown 1 枚から、図入りの HTML スライドを作って検査する |
| `yomiyasu` | 「yomiyasu で推敲して」 | AI が書いた日本語を、意味を保ったまま推敲し、原文と比べて確かめる。頼まなくても、ほかのスキルが作る日本語のページ（スライドは別）はこの決まりで書き、`dockit check` が付属の検査（lint）で本文を読んで、直す所を挙げる。[nanaism/yomiyasu](https://github.com/nanaism/yomiyasu) の写し |

どれが何を受けるか：道具の使い方は `picture-manual`、概念・変更・結果を理解したいときは `explainer`。`doc-kit` はその両方の見た目で、中身がもう決まっているページなら単独で使います。

ほかのプロジェクトから取り込んだものは [NOTICE.md](NOTICE.md) に書いてあります。`explainer` と `explainer-book` のファイルは日本語で書かれていますが、資料は読み手の言語で書きます。`yomiyasu` は日本語で書かれていて、日本語の文章だけを扱います。

## 何をするか

```
頼む ─→ スキルが手順を決める ─→ 本文（部品だけ） ─→ 1 ファイルの HTML ─→ 検査 ─→ 目で見る ─→ 読ませる
          │                        │                   │                  │                │
     picture-manual           見本にある部品        kit.css を埋め込む   dockit check     first-reader
     explainer ほか           （sample.html）       ダークのみ           画面を撮る       （模擬読者）
```

- **読むページの見た目は 1 つ**（例外は、スライドと、`first-reader` が作る読みの記録のページ）：`skills/doc-kit/kit.css`（daisyUI 5 と Tailwind CSS 4 から作り済み）。フォント、文字の大きさ（5 種類）、幅、色はここだけで決まります。ページはダークだけです。
- **部品は見本にあるものだけ**：`skills/doc-kit/sample.html` が、使ってよい部品の一覧です。ビルドに残るのは見本が使うクラスだけなので、見本に無いものはページで効きません。
- **検査**：`dockit check` が、どのスタイルも定義していないクラス（kit にあるのは見本が使うものだけ）、`style=` の属性、古い `kit.css`、部品と同じ名前の絵のクラス、カードと着いた画面で違う見出し、ファイルの外から何かを取ってくる書き方を止めます。
- **渡す前に読ませる**：`first-reader` の模擬読者が、どのページも先に読みます（マニュアルは、使う人が持ってくる「やりたいこと」で探させる。手順は `skills/first-reader/references/lookup.md`。文章は頭から読ませる。本は、最初の章と演習の章）。つまずいた所は、渡す前に直します。省くのは、言葉も順序も変えない直しのときだけです。この読みは欠陥を探すもので、ページが読みやすいことを示すものではありません。
- **1 ファイル**：できたページは、オフラインでもスマホでも開けます。使う側のリポジトリに Node もビルドも要りません（`dockit` は Python 3.9 の標準ライブラリだけ）。
- **言語を問わない**：ページの言語は本文から決まります（地の文にかながあれば日本語、なければ英語。コードは数えません）。`--lang` でも指定できます。フォントは、Mac・Windows・Linux に元からある欧文と日本語の書体です。

部品を足すのは、ページの上ではなく、このリポジトリの見本です。足す前に、持ち主に聞く決まりにしています（部品が少ないことが目的なので）。

## 守られること、守られないこと

上に書いたことの裏にあるものは 3 種類で、強さが違います。

**スクリプトが止めるもの**

- `dockit check` は、次のページを通しません。どのスタイルも定義していないクラス、`style=` の属性、古い `kit.css`、部品と同じ名前の絵のクラス、カードと着いた画面で違う見出し、ページが外から取ってくるふつうの書き方（`src`、`srcset`、フレーム、`<link>`、`@import`、`data:` でも `#id` でもない `url()`、`<meta>` の refresh）。HTML はパーサで読むので、正しく書かれた HTML なら、コメントやスクリプトの中の文字は数えません。
- 止まるのは、検査を走らせた所だけです。Claude はどのページにも走らせます。ページを自分で作るリポジトリは、自分のテストに入れます。
- `doc-fig` の図（ほかの道具が作った図）の中では、クラスが定義されているかを問わず、`style=` も通します。部品と同じ名前の絵のクラスと、外から取ってくる書き方は、図の中でも止めます。
- 検査の相手は、ふつうに書かれたページです。検査をすり抜けるように書かれたページを防ぐ壁ではありません。ページの中のスクリプトが動いたときにすること、エスケープして書いた CSS のキーワード、文字列だけの `image-set()`、ブラウザのパーサでないと解けない HTML、属性セレクタや関数の中にだけ名前が出てくるクラスは通ります。崩れた HTML の一部では、Python 3.9 のパーサと新しいパーサで判定が変わります。
- このリポジトリのテストは、コミットした CSS が元から作ったものと同じかを見ます。`kit` のワークフローは、依存の更新で見本のページの画素が変わらないかを見ます（画像 14 枚、幅 2 つ、Chromium）。ホバー、フォーカス、スクロール中に貼り付く見出し、ほかのブラウザは見ていません。

**Claude に頼んでいるだけのもの（飛ばしても、何も気づかない）**

- 手順を通すことそのもの、日本語を `yomiyasu` の決まりで書くことと lint が挙げた所を直すこと（`dockit check` は日本語のページならいつも挙げますが、それでページを止めはしません）、撮った画面を見ること、模擬読者の読み、`check` が読まない部品の決まり（表の見出しの行、絵のラベル、画面から戻る道）。スキルはプロンプトです。
- だから、渡すときに「やらなかったこと」を言う決まりにしています。頼まれずに最後まで通る割合は、測っていません。

**誰も確かめていないもの**

- 絵がひと目で伝わるか。模擬読者は文字だけを読み、絵を見ません。絵は `picture-manual` のページの主役です。Claude は撮った画面を見ますが、まっさらな目で絵を見る最初の人はあなたです。
- 疲れた人が、模擬の「疲れた読み手」と同じ所まで読むか。「30 秒、画面の最初の 3 分の 1」という制限は、全部の行を読むモデルに頼んでいるだけです。
- 人が読みやすいと感じるか。人の読者と比べた測定も、ベンチマークもありません。ページも、読み手の「やりたいこと」も、判定も、同じ種類のモデルが作っています。1 回の読みは 1 回分の標本です。読み手が見つけたつまずきは本物で、直します。見つからなかったことは、何の証拠にもなりません。

実際にやったこと：探させる読みは、本物のマニュアル 1 本（読み手 2 人、やりたいこと 10 個、2 回）で作りました。書いた手順は、最後に直す前に 1 回だけ、何も知らない状態から試しました。`yomiyasu` の測定と限界は[元のリポジトリ](https://github.com/nanaism/yomiyasu/blob/main/docs/limitations.md)にあります。向こうでも、検査は決まった形を拾うだけで、読みやすいかは人が確かめることになっています。

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
sh scripts/setup-d2.sh   # 次の行のために、初回だけ
pnpm test:figures   # figure-check の回帰テストと、見本のスライドのページ検査（ブラウザと d2 を使う）
```

`pnpm install` は、コミットの前に `pnpm test` を走らせるフック（`.githooks/pre-commit`）を設定します。GitHub Actions が、push とプルリクエストのたびに 2 つのテストを走らせます（`.github/workflows/test.yml`）。依存の更新は Renovate がします（`renovate.json`）。検査で確かめられるものは自動でマージします。見た目の元（daisyUI・Tailwind）は、`kit` のワークフローが更新のブランチで `kit.css` を作り直し、見本のページが前後で 1 ピクセルも変わらなければそのまま通します（`scripts/look.mjs`）。見た目が変わったときだけ、前後の画像を付けて人を待ちます。見本の資料が引用している道具は、測り直しが要るので、Dependency Dashboard で頼んだときだけ更新します。

テーマと色は `src/kit.css` の `@plugin "daisyui"` の行、部品は `src/kit.css` の `doc-` のクラスと `src/sample.html` です。`skills/doc-kit/kit.css` は手で直しません。

既知の点：`figure-check` は、Mermaid の図をコミット済みの SVG とバイト単位で比べます。Mermaid は文字の配置にその機械のフォントを使うので、ある OS で描いた図は、別の OS では「古い」と判定されます。その機械で `--write` を付けて描き直してください。

## 構成

| パス | 内容 |
|---|---|
| `src/kit.css`, `src/sample.html` | 見た目の元。Tailwind と daisyUI の入口、`doc-` の部品、見本の本文（`src/classes.txt` は見本から作る） |
| `skills/doc-kit/` | 見た目のスキル。作り済みの `kit.css` と `sample.html`、`scripts/dockit`（wrap / check / text / lookup） |
| `skills/picture-manual/` | 絵で説明するマニュアル。`scripts/shots.sh` はページの撮影（パソコン幅とスマホ幅） |
| `skills/explainer/`, `skills/explainer-book/` | 読み手 1 人に向けた説明と本。`scripts/build-html.mjs` が kit のページを出す |
| `skills/first-reader/` | 模擬読者（Apache-2.0） |
| `skills/d2-diagram/`, `skills/d2-slides/` | D2 の図とスライド |
| `skills/yomiyasu/` | AI が書いた日本語の推敲と、その検査（MIT）。写しで、ここでは直さない。`scripts/take-yomiyasu.sh` が fork から取り直す |
| `docs/`, `examples/` | 見本の資料（図の道具の使い分け、データの図）と、見本のスライド。どれも `README.md`（英語）と `README.ja.md` がある |
| `tests/` | `test.sh`（全体）と、取り込んだスキルのテスト（`d2/`、`figure-check/`、`first-reader/`。yomiyasu のテストは元のリポジトリにある）、`deck-gates.sh`（見本のスライドのページ検査） |
| `scripts/` | `build-kit.sh`、`look.mjs`（ページの画像。見た目を前後で比べる）、`take-yomiyasu.sh` と、`setup-d2.sh`・`setup-tla.sh`（道具を `.tools/` に取得する） |
| `.claude-plugin/` | プラグインとマーケットプレイスの定義 |
| `.github/`, `.githooks/`, `renovate.json` | push とプルリクエストのときの検査、コミット前の検査、依存の更新 |

## ライセンス

[MIT](LICENSE)。
ほかのプロジェクトから取り込んだものは、元のライセンスに従います。大部分は MIT（`LICENSES/explainer-MIT.txt`）、`skills/first-reader/` は Apache-2.0（同じディレクトリの `LICENSE` と `NOTICE`）、`skills/yomiyasu/` は MIT（同じディレクトリの `LICENSE` と `UNICODE-LICENSE.txt`）です。内訳は [NOTICE.md](NOTICE.md) にあります。
