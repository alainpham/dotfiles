#!/bin/bash
set -euo pipefail

retroarch_version_file="/opt/appimages/retroarch.version"
# https://buildbot.libretro.com/stable/
if [ ! -f /opt/appimages/RetroArch-Linux-x86_64.AppImage ] || [ "$(cat ${retroarch_version_file} 2>/dev/null)" != "${RETROARCH_VERSION}" ]; then
wget -O /tmp/RetroArch.7z https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/linux/x86_64/RetroArch.7z
wget -O /tmp/RetroArch_cores.7z https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/linux/x86_64/RetroArch_cores.7z
cd /tmp/
7z x RetroArch.7z -aoa
7z x RetroArch_cores.7z -aoa
cd -
wget -O /tmp/bios.zip https://github.com/Abdess/retrobios/releases/download/v2026.03.17.2/Lakka_RetroArch_BIOS_Pack.zip
unzip /tmp/bios.zip 'system/*' -d /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/

rm -f /usr/local/bin/retroarch

cat > /usr/local/bin/retroarch << 'EOF'
#!/bin/bash
/opt/appimages/RetroArch-Linux-x86_64.AppImage --appendconfig ~/.config/retroarch/retroarch.override.cfg "$@"
EOF

chmod 755 /usr/local/bin/retroarch

mkdir -p /opt/appimages/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage /opt/appimages/RetroArch-Linux-x86_64.AppImage
chmod 755 /opt/appimages/RetroArch-Linux-x86_64.AppImage
echo "${RETROARCH_VERSION}" > /opt/appimages/retroarch.version

mkdir -p /home/$TARGET_USERNAME/.config/retroarch

rm -rf /home/$TARGET_USERNAME/.config/retroarch/{assets,cores,filters,overlays,shaders,system,database}

mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/assets /home/$TARGET_USERNAME/.config/retroarch/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/cores /home/$TARGET_USERNAME/.config/retroarch/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/filters /home/$TARGET_USERNAME/.config/retroarch/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/overlays /home/$TARGET_USERNAME/.config/retroarch/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/shaders /home/$TARGET_USERNAME/.config/retroarch/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/system /home/$TARGET_USERNAME/.config/retroarch/
mv /tmp/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/database /home/$TARGET_USERNAME/.config/retroarch/

chown -R $TARGET_USERNAME:$TARGET_USERNAME /home/$TARGET_USERNAME/.config/retroarch
else
echo "RetroArch already installed, skipping"
fi
