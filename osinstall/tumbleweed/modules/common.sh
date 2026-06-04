#!/bin/bash
set -euo pipefail

echo copy vars.sh file
cp $TARGETVARS /etc/profile.d/vars.sh
chmod 644 /etc/profile.d/vars.sh
source $TARGETVARS

echo install os scripts
cp /home/$TARGET_USERNAME/dotfiles/scripts/os/* /usr/local/bin/

# fastboot
echo setup fastboot
lineinfile /boot/efi/loader/loader.conf ".*timeout.*" "timeout 1"