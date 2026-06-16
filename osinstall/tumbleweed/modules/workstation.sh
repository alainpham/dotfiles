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

flatpak install -y flathub fr.handbrake.ghb
flatpak install -y flathub com.obsproject.Studio

flatpak install -y flathub io.dbeaver.DBeaverCommunity
flatpak install -y flathub org.kde.kdenlive
flatpak install -y flathub org.onlyoffice.desktopeditors
flatpak install -y flathub com.jgraph.drawio.desktop
flatpak install -y flathub org.beeref.BeeRef
flatpak install -y flathub org.freac.freac
flatpak install -y flathub org.localsend.localsend_app
flatpak install -y flathub org.avidemux.Avidemux
flatpak install -y flathub com.getpostman.Postman
flatpak install -y flathub io.github.antimicrox.antimicrox

flatpak install -y flathub com.viber.Viber
# flatpak install -y flathub us.zoom.Zoom
# flatpak install -y flathub com.slack.Slack

# TODO REAPER
# TODO MLVAPP
