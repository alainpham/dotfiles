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
echo install all custom scripts
for dir in "/home/$TARGET_USERNAME/dotfiles/scripts/"*; do
    if [ -d "$dir" ]; then
        for file in "$dir"/*; do
            [ -e "$file" ] || continue
            cp "$file" /usr/local/bin/
            echo copied file $file
        done
    fi
done

#####################
echo copy whole etc folder
echo network config dnsmasq and powersave
cp -R /home/$TARGET_USERNAME/dotfiles/etc/* /etc/

#####################
echo setting user groups
groupadd -f docker
usermod -aG docker "$TARGET_USERNAME"

groupadd -f input
usermod -aG input "$TARGET_USERNAME"

groupadd -f pipewire
usermod -aG pipewire "$TARGET_USERNAME"

#####################
echo setup fastboot in /boot/efi/loader/loader.conf
bootctl set-timeout 1

#####################
echo install essentials

zypper in -y terminfo

zypper in -y tmux \
    micro-editor \
    ncdu \
    bmon \
    htop \
    btop \
    nvtop \
    virt-what \
    wireguard-tools \
    jc \
    iotop \
    wol \
    stow \
    nmap \
    telnet \
    tini

zypper in -y zip unzip 7zip sshfs lshw libva-utils bchunk
zypper in -y iperf 
zypper in -y growpart

bash $SCRIPT_DIR/../../derivations/speedtest.sh

#####################
echo setup stow dotfiles
cd /home/$TARGET_USERNAME/dotfiles
sudo -u $TARGET_USERNAME stow --no-folding --target=/home/$TARGET_USERNAME --adopt home
sudo -u $TARGET_USERNAME git restore .

#####################
echo passwwordless sudo
if [ "$AUTOMATIC_LOGIN" == "true" ]; then
    echo "${TARGET_USERNAME} ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee' visudo -f /etc/sudoers.d/nopwd
fi

