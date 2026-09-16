#!/bin/bash
set -euo pipefail

export APPNAME=rpcs3
export APPIMAGEURL=https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-2d103407f8715a4feff64012bd2d195878965822/rpcs3-v${RPCS3_VERSION}-2d103407_linux64.AppImage

export APPIMAGEVERSION=${RPCS3_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
