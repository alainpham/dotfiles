#!/bin/bash
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh

export APPNAME=rpcs3
export APPIMAGEURL=${RPCS3_LINK}

export APPIMAGEVERSION=${RPCS3_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
