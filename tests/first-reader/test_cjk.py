#!/usr/bin/env python3
"""Regression test for the explainer project's CJK patch to feed.py."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "skills" / "first-reader" / "scripts"))
import feed  # noqa: E402

# 1 CJK 文字 ≈ 0.5 語。英語の語数は変わらない
assert feed.nwords("hello world") == 2
assert feed.nwords("反例探し") == 2
assert feed.nwords("Z3 は反例探しとして読む") == 1 + 5

# 日本語の段落が 1 つの beat にまとめられすぎないこと (上限 MAX_WORDS 語)
para = "これは検証の結果を読むための段落です。" * 40  # 760 字 ≈ 380 語
chunks = feed.chunk(para)
assert len(chunks) > 1, chunks
assert all(feed.nwords(c) <= feed.MAX_WORDS for c in chunks), [feed.nwords(c) for c in chunks]

# 読む速さの下限も日本語の長さに比例する
assert feed.dwell_floor("あ" * 400, 0.1) > feed.dwell_floor("あ" * 40, 0.1)
# the scanner's view: Japanese text is cut too (it has no spaces to split on), and a sentence ends at 。
import skim  # noqa: E402

assert skim.first_words("a b c d e f g h i j k") == "a b c d e f g h i ..."
long_ja = "和音が変わる直前に、つなぎの音が1つ入るので、ベースの動きが聞こえるようになります"
assert skim.first_words(long_ja) == long_ja[:skim.FIRST_CJK_CHARS] + " ...", skim.first_words(long_ja)
assert skim.first_words("短い行") == "短い行"
assert skim.first_sentence("一文目です。二文目です。") == "一文目です。"
assert skim.first_sentence("First one. Second one.") == "First one."
print("cjk patch tests passed")
