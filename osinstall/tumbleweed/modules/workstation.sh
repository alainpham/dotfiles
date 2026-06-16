#!/bin/bash
set -euo pipefail


zypper in -y \
    gimp \
    rawtherapee \
    krita \
    mypaint \
    pinta \
    inkscape \
    blender \
    godot \
    easytag \
    audacity


flatpak install flathub fr.handbrake.ghb
flatpak install flathub org.kde.kdenlive
flatpak install flathub org.onlyoffice.desktopeditors
flatpak install flathub com.jgraph.drawio.desktop
flatpak install flathub org.freac.freac
flatpak install flathub org.localsend.localsend_app
flatpak install flathub org.avidemux.Avidemux
flatpak install flathub com.getpostman.Postman
flatpak install flathub io.dbeaver.DBeaverCommunity
flatpak install flathub com.obsproject.Studio

# TODO REAPER
# TODO MLVAPP
