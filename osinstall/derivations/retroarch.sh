#!/bin/bash
set -euo pipefail

retroarch_version_file="/opt/appimages/retroarch.version"
# https://buildbot.libretro.com/stable/
if [ ! -f /opt/appimages/RetroArch-Linux-x86_64.AppImage ] || [ "$(cat ${retroarch_version_file} 2>/dev/null)" != "${RETROARCH_VERSION}" ]; then
    workdir="$(mktemp -d /var/tmp/retroarch.XXXXXX)"
    trap 'rm -rf "$workdir"' EXIT

    wget -O "$workdir/RetroArch.7z" "https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/linux/x86_64/RetroArch.7z"
    wget -O "$workdir/RetroArch_cores.7z" "https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/linux/x86_64/RetroArch_cores.7z"
    cd "$workdir"
    7z x "$workdir/RetroArch.7z" -aoa
    7z x "$workdir/RetroArch_cores.7z" -aoa
    wget -O "$workdir/bios.zip" "https://github.com/Abdess/retrobios/releases/download/v2026.08.06/RetroArch_Lakka_v1.22.2_Platform_BIOS_Pack.zip"
    unzip -o "$workdir/bios.zip" -d "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/system/"

rm -f /usr/local/bin/retroarch

cat > /usr/local/bin/retroarch << 'EOF'
#!/bin/bash
/opt/appimages/RetroArch-Linux-x86_64.AppImage --appendconfig ~/.config/retroarch/retroarch.override.cfg "$@"
EOF

chmod 755 /usr/local/bin/retroarch

mkdir -p /opt/appimages/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage" /opt/appimages/RetroArch-Linux-x86_64.AppImage
chmod 755 /opt/appimages/RetroArch-Linux-x86_64.AppImage
echo "${RETROARCH_VERSION}" > /opt/appimages/retroarch.version

mkdir -p /home/$TARGET_USERNAME/.config/retroarch

rm -rf /home/$TARGET_USERNAME/.config/retroarch/{assets,cores,filters,overlays,shaders,system,database}

mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/assets" /home/$TARGET_USERNAME/.config/retroarch/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/cores" /home/$TARGET_USERNAME/.config/retroarch/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/filters" /home/$TARGET_USERNAME/.config/retroarch/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/overlays" /home/$TARGET_USERNAME/.config/retroarch/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/shaders" /home/$TARGET_USERNAME/.config/retroarch/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/system" /home/$TARGET_USERNAME/.config/retroarch/
mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/database" /home/$TARGET_USERNAME/.config/retroarch/

chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/.config/retroarch
else
echo "RetroArch already installed, skipping"
fi
