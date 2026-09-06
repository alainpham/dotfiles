#!/bin/bash
# installing dwm with x11
set -euo pipefail

pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter

mkdir -p /usr/local/bin
ln -sfn /etc/lightdm/Xsession /usr/local/bin/lightdm-session

systemctl enable lightdm.service
systemctl set-default graphical.target

#####################
echo setup keyboard
localectl set-x11-keymap "${KEYBOARD_LAYOUT}" "${KEYBOARD_MODEL}" "${KEYBOARD_VARIANT}" "terminate:ctrl_alt_bksp"

####################
# compile all dwm stuff
pacman -S --needed --noconfirm \
  gcc make cmake \
  libx11 \
  libxft \
  libxrandr \
  imlib2 \
  freetype2 \
  libxinerama \
  ncurses

pacman -S --needed --noconfirm \
  xorg-server xorg-xinit numlockx usbutils 

pacman -S --needed --noconfirm \
  thunar \
  gvfs \
  thunar-volman \
  thunar-archive-plugin \
  thunar-media-tags-plugin \
  engrampa \
  at-spi2-core


pacman -S --needed --noconfirm \
  dunst \
  arandr \
  picom \
  jgmenu \
  simple-scan \
  flameshot \
  maim \
  xclip \
  xdotool \
  xorg-xev \
  libnotify \
  libinput-tools \
  dbus \
  brightnessctl \
  wmctrl

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/x11dwm.sh
bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/gestures.sh

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
