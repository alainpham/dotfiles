#!/bin/bash
set -euo pipefail

export APPNAME=pcsx2
export APPIMAGEURL=https://github.com/PCSX2/pcsx2/releases/download/v${PCSX2_VERSION}/pcsx2-v${PCSX2_VERSION}-linux-appimage-x64-Qt.AppImage
export APPIMAGEVERSION=${PCSX2_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"


mkdir -p /home/$TARGET_USERNAME/.config/PCSX2/bios
wget -O /home/$TARGET_USERNAME/.config/PCSX2/bios/ps2-0230a-20080220.bin https://github.com/archtaurus/RetroPieBIOS/raw/master/BIOS/pcsx2/bios/ps2-0230a-20080220.bin 
chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/.config/PCSX2