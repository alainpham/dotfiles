#!/bin/bash
# installing dwm with x11
set -euo pipefail

#####################
echo setup keyboard
localectl set-x11-keymap "${KEYBOARD_LAYOUT}" "${KEYBOARD_MODEL}" "${KEYBOARD_VARIANT}" ""

#####################
echo setup touchpad
cp /home/$TARGET_USERNAME/dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

####################
# compile all dwm stuff
zypper in -y \
  gcc gcc-c++ make cmake \
  libX11-devel \
  libXft-devel \
  libXrandr-devel \
  imlib2-devel \
  freetype2-devel \
  libXinerama-devel \
  ncurses-devel

zypper in -y xorg-x11-server xinit numlockx usbutils

zypper in -y thunar thunar-archive-plugin thunar-volman thunar-media-tags-plugin

bash $SCRIPT_DIR/../../derivations/x11dwm.sh

if [ "$ENABLE_STARTX" == "true" ]; then
  touch ${ROOTFS}/home/$TARGET_USERNAME/.startxon
fi

if [ "$ENABLE_PICOM" == "true" ]; then
  echo picom enabled
else
  touch "$HOME/.nopicom"
fi
