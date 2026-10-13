#!/bin/bash
set -euo pipefail

# for llama cpp
zypper in -y shaderc shaderc-devel glslang-devel spirv-tools-devel spirv-headers libopenssl-3-devel
# for stable diffusion cpp

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/aitools.sh
