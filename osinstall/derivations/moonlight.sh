#!/bin/bash
set -euo pipefail

if [ ! -f /opt/appimages/moonlight.AppImage ] || [ "$(cat ${ROOTFS}/opt/appimages/moonlight.version 2>/dev/null)" != "${MOONLIGHT_VERSION}" ]; then
    wget -O /opt/appimages/moonlight.AppImage https://github.com/moonlight-stream/moonlight-qt/releases/download/v$MOONLIGHT_VERSION/Moonlight-$MOONLIGHT_VERSION-x86_64.AppImage
    chmod 755 /opt/appimages/moonlight.AppImage
    echo "${MOONLIGHT_VERSION}" > /opt/appimages/moonlight.version
    ln -sf /opt/appimages/moonlight.AppImage /usr/local/bin/moonlight
else
    echo "moonlight already installed, skipping"
fi