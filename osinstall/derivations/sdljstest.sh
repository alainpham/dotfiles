#!/bin/bash
set -euo pipefail

cd /home/$TARGET_USERNAME/wm
git clone https://github.com/Grumbel/sdl-jstest.git

mkdir -p build /home/$TARGET_USERNAME/wm/sdl-jstest/build
 
cd  /home/$TARGET_USERNAME/wm/sdl-jstest
git submodule init
git submodule update
cd /home/$TARGET_USERNAME/wm/sdl-jstest/build && cmake .. && make install

chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/wm
cd -
