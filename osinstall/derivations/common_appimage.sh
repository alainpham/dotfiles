#!/bin/bash
set -euo pipefail

# expect following vars ${APPNAME} ${APPIMAGEURL} ${APPIMAGEVERSION}

# verify required vars are set
required_vars=(APPNAME APPIMAGEURL APPIMAGEVERSION)
for v in "${required_vars[@]}"; do
    if [ -z "${!v:-}" ]; then
        echo "error: required variable $v is not set or empty" >&2
        exit 1
    fi
done


if [ ! -f /opt/appimages/${APPNAME}.AppImage ] || [ "$(cat /opt/appimages/${APPNAME}.version 2>/dev/null)" != "${APPIMAGEVERSION}" ]; then
    wget -O /opt/appimages/${APPNAME}.AppImage ${APPIMAGEURL}
    chmod 755 /opt/appimages/${APPNAME}.AppImage
    echo "${APPIMAGEVERSION}" > /opt/appimages/${APPNAME}.version
    ln -sf /opt/appimages/${APPNAME}.AppImage /usr/local/bin/${APPNAME}
else
    echo "${APPNAME}  already installed, skipping"
fi