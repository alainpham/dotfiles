#!/bin/bash
set -euo pipefail

export APPNAME=ppsspp
export APPIMAGEURL=https://github.com/hrydgard/ppsspp/releases/download/v${PPSSPP_VERSION}/PPSSPP-v${PPSSPP_VERSION}-anylinux-x86_64.AppImage
export APPIMAGEVERSION=${PPSSPP_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"

mkdir -p /home/$TARGET_USERNAME/syncthing/ppsspp/SAVEDATA
mkdir -p /home/$TARGET_USERNAME/syncthing/ppsspp/PPSSPP_STATE
mkdir -p /home/$TARGET_USERNAME/.config/ppsspp/PSP/

rm -rf /home/$TARGET_USERNAME/.config/ppsspp/PSP/SAVEDATA
rm -rf /home/$TARGET_USERNAME/.config/ppsspp/PSP/PPSSPP_STATE

ln -sf /home/$TARGET_USERNAME/syncthing/ppsspp/SAVEDATA /home/${USER}/.config/ppsspp/PSP/SAVEDATA
ln -sf /home/$TARGET_USERNAME/syncthing/ppsspp/PPSSPP_STATE /home/${USER}/.config/ppsspp/PSP/PPSSPP_STATE
