#!/bin/bash
set -euo pipefail

export APPNAME=mgba
export APPIMAGEURL=https://s3.amazonaws.com/mgba/mGBA-build-latest-appimage-x64.appimage
export APPIMAGEVERSION=$(date +"%Y-%m")

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"

