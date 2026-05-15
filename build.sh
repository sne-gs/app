#!/usr/bin/env bash
set -e

if [ ! -f static/output.css ]; then
  echo "==> Generating CSS with Tailwind..."
  ./tailwindcss --input static/app.css --output static/output.css
fi

echo "==> Building Zig binary..."
zig build "$@"

echo "==> Done! Run ./zig-out/bin/app to start the server."
