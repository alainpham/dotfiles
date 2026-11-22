#!/bin/bash
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh

retroarch_version_file="/opt/appimages/retroarch.version"
retroarch_config="/home/$TARGET_USERNAME/.config/retroarch"
bios_dir="$retroarch_config/system"
workdir="$(mktemp -d /var/tmp/retroarch.XXXXXX)"
trap 'rm -rf "$workdir"' EXIT

# https://buildbot.libretro.com/stable/
if [ ! -f /opt/appimages/RetroArch-Linux-x86_64.AppImage ] || [ "$(cat "$retroarch_version_file" 2>/dev/null)" != "$RETROARCH_VERSION" ]; then
    wget -O "$workdir/RetroArch.7z" "https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/linux/x86_64/RetroArch.7z"
    wget -O "$workdir/RetroArch_cores.7z" "https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/linux/x86_64/RetroArch_cores.7z"
    7z x "$workdir/RetroArch.7z" -aoa "-o$workdir"
    7z x "$workdir/RetroArch_cores.7z" -aoa "-o$workdir"

    rm -f /usr/local/bin/retroarch
    cat > /usr/local/bin/retroarch << 'EOF'
#!/bin/bash
/opt/appimages/RetroArch-Linux-x86_64.AppImage --appendconfig ~/.config/retroarch/retroarch.override.cfg "$@"
EOF
    chmod 755 /usr/local/bin/retroarch

    mkdir -p /opt/appimages/
    mv "$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage" /opt/appimages/RetroArch-Linux-x86_64.AppImage
    chmod 755 /opt/appimages/RetroArch-Linux-x86_64.AppImage

    bundled_config="$workdir/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch"
    mkdir -p "$bios_dir"
    rm -rf "$retroarch_config"/{assets,cores,filters,overlays,shaders,database}
    for directory in assets cores filters overlays shaders database; do
        mv "$bundled_config/$directory" "$retroarch_config/"
    done
    if [ -d "$bundled_config/system" ]; then
        cp -a --update=none -- "$bundled_config/system/." "$bios_dir/"
    fi

    chown -R "$TARGET_USERNAME:$TARGET_USERNAME" "$retroarch_config"
    echo "$RETROARCH_VERSION" > "$retroarch_version_file"
else
    echo "RetroArch AppImage already installed"
fi

curl -fsSL --retry 3 -o "$workdir/retrobios-install.sh" https://abdess.github.io/retrobios/i
runuser -u "$TARGET_USERNAME" -- mkdir -p "$bios_dir"
runuser -u "$TARGET_USERNAME" -- sh -s -- --platform retroarch --dest "$bios_dir" --all-files --yes \
    < "$workdir/retrobios-install.sh"
