#!/bin/bash
set -euo pipefail

mkdir -p /usr/share/fonts/nerd-fonts
fontscnt=$(ls /usr/share/fonts/nerd-fonts | wc -l)

if [ "$fontscnt" == "0" ];then
    bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/nerdfonts.sh
fi

pacman -S --needed --noconfirm \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    alacritty \
    brightnessctl \
    upower


# snd
pacman -S --needed --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    lib32-pipewire \
    wireplumber \
    qpwgraph \
    pavucontrol \
    alsa-utils \
    bluetui \
    pipewire-jack

pacman -S --needed --noconfirm \
    ntfs-3g \
    ifuse \
    cmatrix \
    nmon \
    mesa-utils \
    fastfetch \
    feh \
    acpi \
    mkvtoolnix-gui \
    imagemagick \
    mediainfo \
    mediainfo-gui \
    cups \
    simple-scan \
    speedcrunch \
    woff2-font-awesome \
    nwg-look \
    breeze \
    linuxconsole \
    gparted \
    vulkan-tools \
    nss \
    v4l2loopback-dkms \
    v4l2loopback-utils \
    sdl12-compat \
    sdl2-compat \
    sdl3 \
    rofi

# for llamacpp


# themes and Flatpak
pacman -S --needed --noconfirm flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo -u $TARGET_USERNAME flatpak override --user --filesystem=home
flatpak install -y flathub org.filezillaproject.Filezilla
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub org.gnome.Loupe
flatpak install -y flathub org.kde.haruna
flatpak install -y flathub io.mpv.Mpv
flatpak install -y flathub org.videolan.VLC
flatpak install -y flathub dev.lizardbyte.app.Sunshine
flatpak install -y flathub com.moonlight_stream.Moonlight
flatpak install -y flathub org.mozilla.firefox
flatpak install -y flathub com.google.Chrome

#ytdlp
bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/yt.sh

if [ "$SUNSHINE_ON_BOOT" == "true" ]; then
    touch /home/${TARGET_USERNAME}/.sunshineonboot
fi

# VS Code
pacman -S --needed --noconfirm code



# hypervisor
export hypervisor=$(virt-what)
if [ "$hypervisor" = "hyperv" ] || [ "$hypervisor" = "kvm" ]; then
    pacman -S --needed --noconfirm spice-vdagent
fi

if [ "$NUMLOCK_ON_BOOT" == "true" ]; then
systemctl enable nlock

cat << EOF | tee /etc/lightdm/lightdm.conf
[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
EOF
else
systemctl disable nlock
touch /home/${TARGET_USERNAME}/.nonumlock
chown ${TARGET_USERNAME}:${TARGET_USERNAME} /home/${TARGET_USERNAME}/.nonumlock
cat << EOF | tee /etc/lightdm/lightdm.conf
[Seat:*]
greeter-setup-script=/usr/bin/numlockx off
EOF

fi

# if [ "$AUTOMATIC_LOGIN" == "true" ]; then
# mkdir -p /etc/systemd/system/getty@tty1.service.d/
# cat << EOF | tee /etc/systemd/system/getty@tty1.service.d/override.conf
# [Service]
# ExecStart=
# ExecStart=-/usr/sbin/agetty --autologin ${TARGET_USERNAME} --noclear %I \$TERM
# EOF
# fi

if [ "$AUTOMATIC_LOGIN" == "true" ]; then
mkdir -p /etc/lightdm/lightdm.conf.d
groupadd -f autologin
usermod -aG autologin $TARGET_USERNAME
cat << EOF | tee /etc/lightdm/lightdm.conf.d/50-autologin.conf
[Seat:*]
autologin-user=$TARGET_USERNAME
autologin-user-timeout=0
autologin-session=dwm
EOF
fi


echo webapps

export APPDIR=/usr/local/bin
export SHORTCUTDIR=/usr/local/share/applications
mkdir -p /usr/local/share/applications
bash /home/${TARGET_USERNAME}/dotfiles/webapps/genapps
