#!/bin/bash
set -euo pipefail


bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/sdljstest.sh

# auto-agree with licenses when installing packages
pacman -S --needed --noconfirm wine winetricks lutris

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/esde.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/retroarch.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/ppsspp.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/pcsx2.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/rpcs3.sh

pacman -S --needed --noconfirm dolphin-emu

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/cemu.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/mgba.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/gshorts.sh

pacman -S --needed --noconfirm gamemode mangohud mame-tools

# libs for wine
pacman pacman -S --needed --noconfirm \
    lib32-freetype2 lib32-fontconfig lib32-alsa-plugins lib32-libpulse \
    lib32-libxcursor lib32-libxcomposite lib32-libxdamage \
    lib32-libxfixes lib32-libxi lib32-libxinerama \
    lib32-libxkbcommon lib32-libxkbcommon-x11 \
    lib32-libxrandr lib32-libxrender lib32-libxft