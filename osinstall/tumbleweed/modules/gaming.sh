#!/bin/bash
set -euo pipefail

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/sdljstest.sh

zypper in -y wine winetricks lutris


