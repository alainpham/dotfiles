#!/bin/bash
set -euo pipefail

if [ ! -f /opt/appimages/sunshine.AppImage ] || [ "$(cat /opt/appimages/sunshine.version 2>/dev/null)" != "${SUNSHINE_VERSION}" ]; then
    wget -O /opt/appimages/sunshine.AppImage https://github.com/LizardByte/Sunshine/releases/download/v$SUNSHINE_VERSION/sunshine.AppImage
    chmod 755 /opt/appimages/sunshine.AppImage
    echo "${SUNSHINE_VERSION}" > /opt/appimages/sunshine.version
    ln -sf /opt/appimages/sunshine.AppImage /usr/local/bin/sunshine
else
    echo "sunshine already installed, skipping"
fi