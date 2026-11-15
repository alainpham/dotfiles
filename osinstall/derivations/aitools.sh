#!/bin/bash
# installing dwm with x11
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh


# nvm
if [ ! -e "/home/$TARGET_USERNAME/.config/nvm/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | sudo -H -u "$TARGET_USERNAME" env NVM_DIR="/home/$TARGET_USERNAME/.config/nvm" bash
else
    echo nvm already installed
fi

# pi and nvm
sudo -H -u "$TARGET_USERNAME" env NVM_DIR="/home/$TARGET_USERNAME/.config/nvm" bash -c '
    set -e
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    if [ ! -e "$(npm prefix -g)/bin/pi" ]; then
        npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    else
        echo pi already installed
    fi
'

if [ ! -e /home/$TARGET_USERNAME/.opencode/bin/opencode ]; then 
    curl -fsSL https://opencode.ai/install | sudo -u $TARGET_USERNAME bash
else
    echo opencode already installed
fi

if [ ! -e /home/$TARGET_USERNAME/.local/bin/claude ]; then 
    curl -fsSL https://claude.ai/install.sh | sudo -u $TARGET_USERNAME bash
else
    echo claude already installed
fi

if [ ! -e /home/$TARGET_USERNAME/.local/bin/codex ]; then 
    curl -fsSL https://chatgpt.com/codex/install.sh | sudo -H -u "$TARGET_USERNAME" env CODEX_NON_INTERACTIVE=1 sh
else
    echo codex already installed
fi
