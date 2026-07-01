#!/bin/bash
set -euo pipefail

# for llama cpp
zypper in -y shaderc shaderc-devel glslang-devel spirv-tools-devel spirv-headers libopenssl-3-devel
# for stable diffusion cpp

# nvm
if [ ! -e /home/$TARGET_USERNAME/.config/nvm/nvm.sh ]; then 
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | sudo -u $TARGET_USERNAME bash
else
    echo nvm already installed
fi

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


if [ ! -e /home/$TARGET_USERNAME/.local/bin/hf ]; then 
    curl -LsSf https://hf.co/cli/install.sh | sudo -u $TARGET_USERNAME bash
else
    echo hf already installed
fi