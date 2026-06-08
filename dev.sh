#!/usr/bin/env bash

watchexec -r -e zig,html,css --ignore "ui/public/**" -- "zig build && exec ./zig-out/bin/app"
