#!/bin/bash
set -euo pipefail

dnf -y upgrade
dnf -y install ncurses-term
dnf -y install git tmux vim micro ncdu bmon htop btop nvtop virt-what wireguard-tools jc iotop wol stow tini
dnf -y install iperf3 cloud-utils


cd /home/$TARGET_USERNAME
rm -rf dotfiles
sudo -u $TARGET_USERNAME git clone https://github.com/alainpham/dotfiles.git
cd /home/$TARGET_USERNAME/dotfiles
sudo -u $TARGET_USERNAME stow --no-folding --target=/home/$TARGET_USERNAME --adopt home
sudo -u $TARGET_USERNAME git restore .

if [ !"$AUTOMATIC_LOGIN" == "true" ]; then

fi