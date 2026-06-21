#!/bin/bash
set -euo pipefail

export APPNAME=mlvapp
export APPIMAGEURL=https://github.com/ilia3101/MLV-App/releases/download/Qtv${MLVAPP_VERSION}/MLVApp.v${MLVAPP_VERSION}.Linux.x86_64.AppImage
export APPIMAGEVERSION=${MLVAPP_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
