#!/bin/bash
# installing dwm with x11
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh

rm -rf /home/$TARGET_USERNAME/gshorts
cd /home/$TARGET_USERNAME/
git clone https://github.com/alainpham/gshorts.git
cd /home/$TARGET_USERNAME/gshorts
bash install.sh
chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/gshorts
