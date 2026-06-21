#!/bin/bash
set -euo pipefail

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/sdljstest.sh

zypper in -y wine winetricks lutris

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/esde.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/retroarch.sh
