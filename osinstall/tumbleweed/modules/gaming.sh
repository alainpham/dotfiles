#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p build /home/$TARGET_USERNAME/wm/sdl-jstest/build
cd  /home/$TARGET_USERNAME/wm/sdl-jstest
git submodule init
git submodule update
cd /home/$TARGET_USERNAME/wm/sdl-jstest/build && cmake .. && make install
