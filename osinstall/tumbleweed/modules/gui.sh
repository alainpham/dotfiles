#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fontscnt=$(ls /usr/share/fonts/nerd-fonts | wc -l)

if [ "$fontscnt" == "0" ];then
    bash $SCRIPT_DIR/../../derivations/nerdfonts.sh
fi

zypper in -y \
    google-noto-fonts \
    alacritty \
    brightnessctl \
    upower

# snd
zypper in -y pipewire \
    pipewire-pulseaudio \
    pipewire-alsa \
    pipewire-alsa-32bit \
    pipewire-jack \
    wireplumber \
    qpwgraph \
    pavucontrol-qt \
    bluetui

zypper in -y \
    ntfs-3g \
    ifuse \
    mpv \
    haruna \
    vlc \
    cmatrix \
    nmon \
    Mesa-demo-x \
    fastfetch \
    feh \
    qimgv \
    acpi \
    mkvtoolnix-gui \
    ImageMagick \
    mediainfo \
    mediainfo-gui \
    cups \
    xsane \
    filezilla \
    speedcrunch \
    fontawesome-fonts \
    fontawesome-fonts-web \
    lxappearance \
    nwg-look \
    breeze6 \
    linuxconsoletools \
    gparted \
    vulkan-tools \
    mozilla-nss-tools

zypper in -y flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal

#ytdlp
bash $SCRIPT_DIR/../../derivations/yt.sh

# chrome
mkdir -p /opt/rpms/
rpm --import https://dl.google.com/linux/linux_signing_key.pub
wget -O /opt/rpms/google-chrome-stable_current_x86_64.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
zypper install -y /opt/rpms/google-chrome-stable_current_x86_64.rpm

