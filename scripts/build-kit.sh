#!/bin/sh
# Build the kit's CSS from src/ into the file given (default: skills/doc-kit/kit.css).
# Tailwind reads every word of a file it scans as a possible class, so it is given the sample's class
# attributes only (src/classes.txt), not the sample with its prose.
set -eu
cd "$(dirname "$0")/.."
out=${1:-skills/doc-kit/kit.css}
python3 skills/doc-kit/scripts/dockit classes src/sample.html > src/classes.txt
pnpm exec tailwindcss -i src/kit.css -o "$out" --minify
