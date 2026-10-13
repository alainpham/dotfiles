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

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/aitools.sh
