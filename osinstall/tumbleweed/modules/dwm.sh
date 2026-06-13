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

zypper in -y thunar \
  thunar-archive-plugin \
  thunar-volman \
  thunar-media-tags-plugin \


zypper in -y dunst \
  dunst-bash-completion \
  arandr \
  picom \
  jgmenu \
  xsane \
  flameshot \
  maim \
  xclip \
  xdotool \
  xev \
  libnotify-tools \
  libinput-tools \
  dbus-1-daemon \
  wmctrl

zypper in -y rofi

bash $SCRIPT_DIR/../../derivations/x11dwm.sh
bash $SCRIPT_DIR/../../derivations/gestures.sh

if [ "$ENABLE_STARTX" == "true" ]; then
  touch /home/$TARGET_USERNAME/.startxon
  chown $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/.startxon
fi

if [ "$ENABLE_PICOM" == "true" ]; then
  echo picom enabled
else
  touch "/home/$TARGET_USERNAME/.nopicom"
  chown $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/.nopicom
fi
