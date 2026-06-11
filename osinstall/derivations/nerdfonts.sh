#!/bin/bash
set -euo pipefail

echo "install nerdfonts"
for font in ${NERDFONTS} ; do
 echo "installing $font"
 wget -O /tmp/${font}.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
 mkdir -p /usr/share/fonts/nerd-fonts/
 unzip -o /tmp/${font}.zip -d /usr/share/fonts/nerd-fonts/
 rm -f /tmp/${font}.zip
 echo "installed $font"
done
