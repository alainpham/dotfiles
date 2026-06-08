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
echo network config dnsmasq and powersave
cp /home/$TARGET_USERNAME/dotfiles/etc/NetworkManager/conf.d/* /etc/NetworkManager/conf.d/

mkdir -p /etc/NetworkManager/dnsmasq.d
cat << EOF | tee /etc/NetworkManager/dnsmasq.d/dev.conf
#/etc/NetworkManager/dnsmasq.d/dev.conf
local=/${WILDCARD_DOMAIN}/
address=/${WILDCARD_DOMAIN}/172.18.0.1
local=/${K3S_WILDCARD_DOMAIN}/
address=/${K3S_WILDCARD_DOMAIN}/172.18.0.1
EOF

# allow nmcli reload
cat << EOF | tee /etc/polkit-1/rules.d/49-nmcli-reload.rules
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.NetworkManager.reload" &&
        subject.isInGroup("${TARGET_USERNAME}")) {
        return polkit.Result.YES;
    }
});
EOF

mkdir -p /home/$TARGET_USERNAME/virt/runtime
touch /etc/NetworkManager/dnsmasq.d/vms
chown $TARGET_USERNAME:$TARGET_USERNAME /etc/NetworkManager/dnsmasq.d/vms
ln -sf /etc/NetworkManager/dnsmasq.d/vms /home/$TARGET_USERNAME/virt/runtime/vms
chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/virt/runtime

#####################
echo passwwordless sudo
if [ "$AUTOMATIC_LOGIN" == "true" ]; then
    echo "${TARGET_USERNAME} ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee' visudo -f /etc/sudoers.d/nopwd
fi

# To be put in GUI later
#####################
echo setup keyboard
localectl set-x11-keymap "${KEYBOARD_LAYOUT}" "${KEYBOARD_MODEL}" "${KEYBOARD_VARIANT}" ""

#####################
echo setup touchpad
cp /home/$TARGET_USERNAME/dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/
