#!/bin/bash
# installing dwm with x11
set -euo pipefail

rm -rf /home/$TARGET_USERNAME/wm
mkdir -p /home/$TARGET_USERNAME/wm
cd /home/$TARGET_USERNAME/wm
git clone https://github.com/alainpham/dwm-flexipatch.git
git clone https://github.com/alainpham/dwmblocks.git
git clone https://github.com/alainpham/slock-flexipatch.git

cd /home/$TARGET_USERNAME/wm/dwm-flexipatch && make clean install
cd /home/$TARGET_USERNAME/wm/dwmblocks && make clean install
cd /home/$TARGET_USERNAME/wm/slock-flexipatch && make clean install

chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/wm
