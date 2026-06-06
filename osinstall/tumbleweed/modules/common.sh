#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# echo refresh repos
# zypper ref
# echo upgrade system
# zypper dup -y

#####################
echo copy vars.sh file
cp $TARGETVARS /etc/profile.d/vars.sh
chmod 644 /etc/profile.d/vars.sh
source $TARGETVARS

echo copy sources.sh file
cp $SCRIPT_DIR/../../sources.sh /etc/profile.d/sources.sh
chmod 644 /etc/profile.d/sources.sh
source /etc/profile.d/sources.sh

#####################
echo install os scripts
cp /home/$TARGET_USERNAME/dotfiles/scripts/os/* /usr/local/bin/

#####################
echo setup fastboot in /boot/efi/loader/loader.conf
bootctl set-timeout 1

#####################
echo setup small log usage
cp /home/$TARGET_USERNAME/dotfiles/etc/systemd/journald.conf.d/limits.conf /etc/systemd/journald.conf.d

#####################
echo install essentials

zypper in terminfo

zypper in -y tmux micro-editor ncdu bmon htop btop nvtop virt-what wireguard-tools jc iotop wol stow tini
zypper in -y iperf 
zypper in -y growpart

bash $SCRIPT_DIR/../../derivations/speedtest.sh