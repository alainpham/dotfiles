#!/bin/bash
set -euo pipefail

echo copy vars.sh file
cp $TARGETVARS /etc/profile.d/vars.sh
chmod 644 /etc/profile.d/vars.sh
source $TARGETVARS

echo install os scripts
cp /home/$TARGET_USERNAME/dotfiles/scripts/os/* /usr/local/bin/

# fastboot
echo setup fastboot in /boot/efi/loader/loader.conf
bootctl set-timeout 1

echo setup small log usage
cp /home/$TARGET_USERNAME/dotfiles/etc/systemd/journald.conf.d/limits.conf /etc/systemd/journald.conf.d
