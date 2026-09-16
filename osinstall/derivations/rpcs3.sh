#!/bin/bash
set -euo pipefail

export APPNAME=rpcs3
export APPIMAGEURL=${RPCS3_LINK}

export APPIMAGEVERSION=${RPCS3_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
