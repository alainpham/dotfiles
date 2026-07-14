#!/bin/bash
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh

#####################
echo setup fastboot in grub
mkdir -p /etc/default/grub.d/
echo 'GRUB_TIMEOUT=1' | tee /etc/default/grub.d/15_timeout.cfg

#####################
echo install essentials
apt -y update 
apt install -y ncurses-term
apt upgrade -y 
apt install -y \
    tmux \
    micro \
    ncdu \
    htop \
    btop \
    nvtop \
    virt-what \
    wireguard-tools \
    iotop \
    wakeonlan \
    stow \
    nmap \
    telnet \
    zip \
    unzip \
    7zip \
    sshfs \
    lshw \
    vainfo \
    iperf \
    cloud-guest-utils \
    bmon \
    jc \
    tini \
    bchunk

cat << EOF | tee /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF