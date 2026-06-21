#!/bin/bash
set -euo pipefail


bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/sdljstest.sh

# auto-agree with licenses when installing packages
zypper in -y --auto-agree-with-licenses wine winetricks lutris

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/esde.sh

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/retroarch.sh
