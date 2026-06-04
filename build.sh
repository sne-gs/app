#!/usr/bin/env bash
set -e

echo "==> Building HTML"
hugo -s ui --minify

echo "==> Building CSS"
tailwindcss --minify --input ui/static/app.css --output ui/public/output.css

echo "==> Building Zig"
zig build "$@"

echo "==> Build complete."
