#!/bin/sh
# Fetch D2 (TALA / ELK / dagre bundled) into .tools/ for this OS and CPU. figure-check.mjs uses .tools/d2.
set -eu
V=v0.9.0
case "$(uname -s)" in
  Darwin) os=macos ;;
  Linux) os=linux ;;
  *) echo "setup-d2: unsupported OS $(uname -s): install d2 from https://d2lang.com and put it on PATH" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  arm64|aarch64) cpu=arm64 ;;
  x86_64|amd64) cpu=amd64 ;;
  *) echo "setup-d2: unsupported CPU $(uname -m)" >&2; exit 1 ;;
esac
f="d2-$V-$os-$cpu.tar.gz"
base="https://github.com/terrastruct/d2/releases/download/$V"
mkdir -p .tools
if [ ! -x .tools/d2 ]; then
  curl -fsSL -o ".tools/$f" "$base/$f"
  curl -fsSL -o .tools/SHA256SUMS "$base/SHA256SUMS"
  # the release's own checksum: a download that does not match is not unpacked
  (cd .tools && grep " $f\$" SHA256SUMS > "$f.sum" && { if command -v sha256sum >/dev/null; then sha256sum -c "$f.sum"; else shasum -a 256 -c "$f.sum"; fi; })
  tar xzf ".tools/$f" -C .tools
  rm ".tools/$f" ".tools/$f.sum" .tools/SHA256SUMS
  ln -sfn "d2-$V/bin/d2" .tools/d2
fi
.tools/d2 --version
