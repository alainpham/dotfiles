#!/bin/bash
set -euo pipefail

previousfld=$(pwd)
cd /tmp/
rm -rf libinput-gestures
git clone https://github.com/bulletmark/libinput-gestures.git
cd libinput-gestures
./libinput-gestures-setup install
cd $previousfld

