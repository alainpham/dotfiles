#!/bin/bash
set -euo pipefail

export APPNAME=emustation
export APPIMAGEURL=https://github.com/ilia3101/MLV-App/releases/download/Qtv${MLVAPP_VERSION}/MLVApp.v${MLVAPP_VERSION}.Linux.x86_64.AppImage
export APPIMAGEVERSION=${ESDE_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
