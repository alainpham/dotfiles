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
    
    add_or_ignore_repo() {
        url="$1"
        if zypper lr -u | awk '{print $NF}' | grep -Fxq "$url"; then
            echo "repo $url already exists, skipping"
        else
            zypper addrepo --refresh "$url" || echo "failed to add $url (ignored)"
        fi
    }

    add_or_ignore_repo "https://download.opensuse.org/repositories/Virtualization:containers/${VERSION_ID}/Virtualization:containers.repo"
    add_or_ignore_repo "https://download.opensuse.org/repositories/multimedia:apps/${VERSION_ID}/multimedia:apps.repo"
    add_or_ignore_repo "https://download.opensuse.org/repositories/utilities/${VERSION_ID}/utilities.repo"
    add_or_ignore_repo "https://download.opensuse.org/repositories/network:utilities/${VERSION_ID}/network:utilities.repo"

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
