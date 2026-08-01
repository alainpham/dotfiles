#!/bin/bash
set -euo pipefail

export APPNAME=pcsx2
export APPIMAGEURL=https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-f113e7bb9380555c64b3031ad17e64c3ca85e2c8/rpcs3-v${RPCS3_VERSION}-19677-f113e7bb_linux64.AppImage
export APPIMAGEVERSION=${RPCS3_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
