#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash $SCRIPT_DIR/../../derivations/nerdfonts.sh

zypper in -y google-noto-fonts rofi alacritty

zypper in -y flatpak


cp -R /home/$TARGET_USERNAME/dotfiles/scripts/desktop/* ${ROOTFS}/usr/local/bin/
cp -R /home/$TARGET_USERNAME/dotfiles/scripts/sound/* ${ROOTFS}/usr/local/bin/
cp -R /home/$TARGET_USERNAME/dotfiles/scripts/av/* ${ROOTFS}/usr/local/bin/
cp -R /home/$TARGET_USERNAME/dotfiles/scripts/webcam/* ${ROOTFS}/usr/local/bin/
