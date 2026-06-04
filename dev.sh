#!/usr/bin/env bash

cleanup() {
    echo "Cleaning up..."
    jobs -p | xargs -r kill -TERM 2>/dev/null
    exit
}
trap cleanup INT TERM

./build.sh

watchexec --restart --watch ui/content/ --watch ui/layouts/ --watch ui/static/app.css --exts html,css -- ./build.sh &
WATCHEXEC_PID=$!

zig build run --watch -- --port 8080

kill $WATCHEXEC_PID
