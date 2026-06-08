#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

zypper in -y docker docker-compose skopeo skopeo-bash-completion docker-buildx
zypper in -y docker-bash-completion

systemctl enable --now docker

usermod -aG docker $TARGET_USERNAME

mkdir -p /etc/docker

cp /home/$TARGET_USERNAME/dotfiles/etc/docker/* /etc/docker/
echo "docker logs configured"
