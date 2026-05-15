#!/usr/bin/env bash
set -e

fuser -k 3000/tcp 2>/dev/null || true

if [ ! -f static/output.css ]; then
  echo "==> Generating CSS (first build)..."
  ./tailwindcss --minify --input static/app.css --output static/output.css
fi

echo "==> Building..."
zig build

echo "==> Starting server..."
./zig-out/bin/app
