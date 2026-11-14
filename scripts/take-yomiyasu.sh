#!/bin/sh
# skills/yomiyasu is a copy, never edited here: change it in the fork, then take it again.
#   sh scripts/take-yomiyasu.sh [ref]     (a tag, a branch or a commit of the fork; default: main)
# The fork (github.com/chaudepark/yomiyasu) follows github.com/nanaism/yomiyasu, the skill's own repository.
set -eu
cd "$(dirname "$0")/.."
ref=${1:-main}
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT
curl -fsSL "https://codeload.github.com/chaudepark/yomiyasu/tar.gz/$ref" -o "$tmp/src.tgz"
# the archive carries the commit it was made from
from=$(gzip -dc "$tmp/src.tgz" | git get-tar-commit-id)
mkdir "$tmp/src"
tar -xzf "$tmp/src.tgz" -C "$tmp/src" --strip-components 1
test -f "$tmp/src/skills/yomiyasu/SKILL.md"
# a tracked file the fork no longer has goes too (git keeps what it removes; an untracked leftover stays)
if [ -d skills/yomiyasu ]; then git rm -r -q --ignore-unmatch skills/yomiyasu; fi
mkdir -p skills/yomiyasu
cp -R "$tmp/src/skills/yomiyasu/." skills/yomiyasu/
echo "$from" > skills/yomiyasu/FROM
# staged again as it now is: without this a commit of what is staged would remove the skill
git add -A skills/yomiyasu
echo "took skills/yomiyasu at $from (staged): name that commit in NOTICE.md, then pnpm test"
