#!/bin/bash
set -euo pipefail

export APPNAME=ppsspp
export APPIMAGEURL=https://github.com/hrydgard/ppsspp/releases/download/v${PPSSPP_VERSION}/PPSSPP-v${PPSSPP_VERSION}-anylinux-x86_64.AppImage
export APPIMAGEVERSION=${PPSSPP_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"

