#!/bin/bash
set -euo pipefail


bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/sdljstest.sh

# auto-agree with licenses when installing packages
zypper in -y --auto-agree-with-licenses wine winetricks lutris

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/esde.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/retroarch.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/ppsspp.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/pcsx2.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/rpcs3.sh

zypper in -y dolphin-emu

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/cemu.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/mgba.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/gshorts.sh

zypper in -y gamemode mangohud