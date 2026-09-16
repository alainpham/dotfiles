#!/bin/bash
set -euo pipefail

source /etc/profile.d/sources.sh

export APPNAME=estation
export APPIMAGEURL=https://gitlab.com/es-de/emulationstation-de/-/package_files/${ESDE_VERSION_ID}/download
export APPIMAGEVERSION=${ESDE_VERSION}

bash "/home/$TARGET_USERNAME/dotfiles/osinstall/derivations/common_appimage.sh"
