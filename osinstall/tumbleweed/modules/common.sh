#!/bin/bash
set -euo pipefail

# echo refresh repos
# zypper ref
# echo upgrade system
# zypper dup -y

#####################
echo copy vars.sh file
cp $TARGETVARS /etc/profile.d/vars.sh
chmod 644 /etc/profile.d/vars.sh
source /etc/profile.d/vars.sh

echo copy sources.sh file
cp /home/$TARGET_USERNAME/dotfiles/osinstall/sources.sh /etc/profile.d/sources.sh
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

mkdir -p /usr/local/share/icons
cp -r /home/$TARGET_USERNAME/dotfiles/icons/* /usr/local/share/icons


#####################
echo install etc files
echo network config dnsmasq and powersave
ETC_SRC="/home/$TARGET_USERNAME/dotfiles/etc"
find "$ETC_SRC" -type f | while read -r file; do
    rel="${file#$ETC_SRC/}"
    if [[ "$file" == *.envsubst ]]; then
        dest="/etc/${rel%.envsubst}"
        sudo mkdir -p "$(dirname "$dest")"
        envsubst < "$file" | sudo tee "$dest" > /dev/null
        echo "applied envsubst and copied $file -> $dest"
    else
        dest="/etc/$rel"
        sudo mkdir -p "$(dirname "$dest")"
        sudo cp "$file" "$dest"
        echo "copied $file -> $dest"
    fi
done

# hostnamectl hostname $HOSTNAME

#####################
echo setting user groups

groups=(docker input pipewire kvm libvirt render)
for group in "${groups[@]}"; do
    groupadd -f "$group"
    usermod -aG "$group" "$TARGET_USERNAME"
    echo added to group $group
done

#####################
echo setup fastboot in /boot/efi/loader/loader.conf
bootctl set-timeout 1

#####################
echo install essentials

zypper in -y terminfo \
    tmux \
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
    tini \
    zip \
    unzip \
    7zip \
    sshfs \
    lshw \
    libva-utils \
    bchunk \
    iperf \
    growpart


bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/speedtest.sh

#####################
echo setup stow dotfiles
prevfld=$(pwd)
cd /home/$TARGET_USERNAME/dotfiles
sudo -u $TARGET_USERNAME stow --no-folding --target=/home/$TARGET_USERNAME --adopt home
sudo -u $TARGET_USERNAME git restore .
cd $prevfld

#####################
echo passwwordless sudo
if [ "$AUTOMATIC_LOGIN" == "true" ]; then
    echo "${TARGET_USERNAME} ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee' visudo -f /etc/sudoers.d/nopwd
fi


if [ "$DISABLE_TURBO_BOOST" == "true" ]; then
    systemctl enable disable-intel-turboboost.service
else
    systemctl disable disable-intel-turboboost.service
fi

export hypervisor=$(virt-what)

if [ "$hypervisor" = "hyperv" ] || [ "$hypervisor" = "kvm" ]; then
    firstboot
fi