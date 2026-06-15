#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p /usr/share/fonts/nerd-fonts
fontscnt=$(ls /usr/share/fonts/nerd-fonts | wc -l)

if [ "$fontscnt" == "0" ];then
    bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/nerdfonts.sh
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
    wireplumber \
    qpwgraph \
    pavucontrol \
    alsa-utils \
    bluetui

zypper install --force-resolution -y pipewire-jack

zypper in -y \
    ntfs-3g \
    ifuse \
    mpv \
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
    MozillaFirefox \
    speedcrunch \
    fontawesome-fonts \
    fontawesome-fonts-web \
    nwg-look \
    breeze6 \
    linuxconsoletools \
    gparted \
    vulkan-tools \
    mozilla-nss-tools \
    v4l2loopback-utils \
    SDL2 \
    rofi


zypper in -y flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub org.kde.haruna
flatpak install -y flathub dev.lizardbyte.app.Sunshine
flatpak install -y flathub com.moonlight_stream.Moonlight

#ytdlp
bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/yt.sh

if [ "$SUNSHINE_ON_BOOT" == "true" ]; then
    touch /home/${TARGET_USERNAME}/.sunshineonboot
fi

# chrome
if [ ! -f /opt/rpms/google-chrome-stable_current_x86_64.rpm ];then
    mkdir -p /opt/rpms/
    rpm --import https://dl.google.com/linux/linux_signing_key.pub
    wget -O /opt/rpms/google-chrome-stable_current_x86_64.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
fi
zypper install -y /opt/rpms/google-chrome-stable_current_x86_64.rpm

if [ ! -f /opt/rpms/vscode.rpm ]; then
    mkdir -p /opt/rpms/
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    wget -O /opt/rpms/vscode.rpm "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
fi
zypper install -y /opt/rpms/vscode.rpm



# hypervisor
export hypervisor=$(virt-what)
if [ "$hypervisor" = "hyperv" ] || [ "$hypervisor" = "kvm" ]; then
    zypper in -y spice-vdagent
fi

if [ "$NUMLOCK_ON_BOOT" == "true" ]; then
    systemctl enable nlock
else
    systemctl disable nlock
    touch /home/${TARGET_USERNAME}/.nonumlock
    chown ${TARGET_USERNAME}:${TARGET_USERNAME} /home/${TARGET_USERNAME}/.nonumlock
fi

if [ "$AUTOMATIC_LOGIN" == "true" ]; then
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat << EOF | tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/sbin/agetty --autologin ${TARGET_USERNAME} --noclear %I \$TERM
EOF
fi


echo webapps

export APPDIR=/usr/local/bin
export SHORTCUTDIR=/usr/local/share/applications
mkdir -p /usr/local/share/applications
bash /home/${TARGET_USERNAME}/dotfiles/webapps/genapps
