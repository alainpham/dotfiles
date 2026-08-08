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
