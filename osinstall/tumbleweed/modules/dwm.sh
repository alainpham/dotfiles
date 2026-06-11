#!/bin/bash
# installing dwm with x11
set -euo pipefail

#####################
echo setup keyboard
localectl set-x11-keymap "${KEYBOARD_LAYOUT}" "${KEYBOARD_MODEL}" "${KEYBOARD_VARIANT}" ""

#####################
echo setup touchpad
cp /home/$TARGET_USERNAME/dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

zypper in -y \
  gcc make cmake \
  libX11-devel \
  libXft-devel \
  libXrandr-devel \
  imlib2-devel \
  freetype2-devel \
  libXinerama-devel \
  xorg-x11-server xinit numlockx usbutils

