#!/usr/bin/env bash

pkill -f "zig-out/bin/app" 2>/dev/null || true

watchexec -r -e zig,html,css --ignore "ui/public/**" -- "zig build && exec ./zig-out/bin/app"
