#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usermod -aG input $TARGET_USERNAME

bash $SCRIPT_DIR/../../derivations/nerdfonts.sh

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

zypper in -y 

zypper in -y flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal

#ytdlp
bash $SCRIPT_DIR/../../derivations/yt.sh

# chrome
bash $SCRIPT_DIR/../../derivations/chrome.sh
cp -R /home/$TARGET_USERNAME/dotfiles/etc/opt /etc/

cp -R /home/$TARGET_USERNAME/dotfiles/scripts/av/* ${ROOTFS}/usr/local/bin/
cp -R /home/$TARGET_USERNAME/dotfiles/scripts/desktop/* ${ROOTFS}/usr/local/bin/
cp -R /home/$TARGET_USERNAME/dotfiles/scripts/sound/* ${ROOTFS}/usr/local/bin/
cp -R /home/$TARGET_USERNAME/dotfiles/scripts/webcam/* ${ROOTFS}/usr/local/bin/
