#!/usr/bin/env bash
set -e

echo "==> Building CSS"
tailwindcss --minify --input static/app.css --output static/output.css

echo "==> Building Zig binary"
zig build "$@"

echo "==> Done. Run ./zig-out/bin/app to start the server."
