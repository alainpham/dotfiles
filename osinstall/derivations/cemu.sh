#!/bin/bash
set -euo pipefail

export APPNAME=cemu
export APPIMAGEURL=https://github.com/cemu-project/Cemu/releases/download/v$CEMU_VERSION/Cemu-$CEMU_VERSION-x86_64.AppImage
export APPIMAGEVERSION=${CEMU_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"

