#!/bin/bash
# installing dwm with x11
set -euo pipefail

source /etc/profile.d/vars.sh
source /etc/profile.d/sources.sh


# nvm
if [ ! -e "/home/$TARGET_USERNAME/.nvm/nvm.sh" ]; then
    mkdir /home/$TARGET_USERNAME/.nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | sudo -H -u "$TARGET_USERNAME" bash -c 'export NVM_DIR="${HOME}/.nvm"; exec bash'
else
    echo nvm already installed
fi

# pi in nvm
sudo -H -u "$TARGET_USERNAME" bash -c '
    set -e
    export NVM_DIR="${HOME}/.nvm"
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    nvm alias default "lts/*"
    if [ ! -e "$(npm prefix -g)/bin/pi" ]; then
        npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    else
        echo pi already installed
    fi
    pi install npm:pi-llama-cpp
    pi install npm:pi-web-access
    pi install npm:pi-playwright
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
