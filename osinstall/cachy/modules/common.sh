#!/bin/bash
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh

#####################
echo setup fastboot in /boot/efi/loader/loader.conf
if bootctl is-installed; then
    bootctl set-timeout 1
fi

#####################
echo install essentials

pacman -Syu --noconfirm
pacman -S --needed --noconfirm \
    ncurses \
    tmux \
    micro \
    ncdu \
    htop \
    btop \
    nvtop \
    virt-what \
    wireguard-tools \
    iotop-c \
    wol \
    stow \
    nmap \
    inetutils \
    zip \
    unzip \
    7zip \
    sshfs \
    lshw \
    libva-utils \
    iperf3 \
    cloud-guest-utils \
    bmon \
    jc \
    bchunk
