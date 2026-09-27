#!/bin/bash
set -euo pipefail

# for llama cpp
pacman -S --needed --noconfirm \
    shaderc \
    glslang \
    spirv-tools \
    spirv-headers \
    openssl
# for stable diffusion cpp

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | sudo -u $TARGET_USERNAME bash

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

if [ ! -e /home/$TARGET_USERNAME/.local/bin/pi ]; then 
    sudo -u $TARGET_USERNAME bash -lc 'npm install -g --ignore-scripts --min-release-age=0 --prefix /home/user/.local @earendil-works/pi-coding-agent'
else
    echo pi already installed
fi



if [ ! -e /home/$TARGET_USERNAME/.local/bin/dsh ]; then 
    sudo -u $TARGET_USERNAME bash -lc 'npm install -g --prefix /home/user/.local  @deepseek-ai/dsh'
else
    echo pi already installed
fi




if [ ! -e /home/$TARGET_USERNAME/.local/bin/hf ]; then 
    curl -LsSf https://hf.co/cli/install.sh | sudo -u $TARGET_USERNAME bash
else
    echo hf already installed
fi
