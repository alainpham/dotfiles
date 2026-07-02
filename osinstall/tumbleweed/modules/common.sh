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

groups=(docker input pipewire kvm video render libvirt render gamemode)
for group in "${groups[@]}"; do
    groupadd -f "$group"
    usermod -aG "$group" "$TARGET_USERNAME"
    echo added to group $group
done

#####################
echo setup fastboot in /boot/efi/loader/loader.conf
if bootctl is-installed; then
    bootctl set-timeout 1
fi

#####################
echo install essentials

echo enable oss, non-oss and openh264 repos
# alias names differ between variants (e.g. "repo-oss" on Tumbleweed vs
# "openSUSE:repo-oss" on Leap 16), so match by the trailing repo name.
for repo in repo-oss repo-non-oss repo-openh264 repo-update; do
    alias=$(zypper repos | awk -F'|' -v r="$repo" '{gsub(/ /,"",$2); if ($2 == r || $2 ~ ":"r"$") print $2}' | head -n1)
    if [ -n "$alias" ]; then
        sudo zypper mr -e "$alias"
        echo enabled repo $alias
    else
        echo "repo $repo not found, skipping"
    fi
done

. /etc/os-release
if [ "$ID" = "opensuse-leap" ]; then
    echo add Virtualization:containers repo for Leap
    zypper addrepo --refresh https://download.opensuse.org/repositories/Virtualization:containers/${VERSION_ID}/Virtualization:containers.repo
    zypper addrepo --refresh https://download.opensuse.org/repositories/multimedia:apps/${VERSION_ID}/multimedia:apps.repo
    zypper addrepo --refresh https://download.opensuse.org/repositories/utilities/${VERSION_ID}/utilities.repo
    zypper addrepo --refresh https://download.opensuse.org/repositories/network:utilities/16.0/network:utilities.repo

    zypper --gpg-auto-import-keys refresh
fi


zypper in -y terminfo \
    tmux \
    micro-editor \
    ncdu \
    htop \
    btop \
    nvtop \
    virt-what \
    wireguard-tools \
    iotop \
    wol \
    stow \
    nmap \
    telnet \
    zip \
    unzip \
    7zip \
    sshfs \
    lshw \
    libva-utils \
    iperf \
    growpart \
    bmon\
    jc \
    tini \
    bchunk

# these are only packaged on Tumbleweed, not Leap 16


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
    echo todo
    # firstboot
fi

#####################
echo setup ssh authorized keys
mkdir -p /home/$TARGET_USERNAME/.ssh
chmod 700 /home/$TARGET_USERNAME/.ssh
curl -s https://github.com/alainpham.keys > /home/$TARGET_USERNAME/.ssh/authorized_keys
chmod 600 /home/$TARGET_USERNAME/.ssh/authorized_keys
chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/.ssh

