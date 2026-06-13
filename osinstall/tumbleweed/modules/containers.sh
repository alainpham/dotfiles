#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

zypper in -y docker docker-compose skopeo skopeo-bash-completion docker-buildx
zypper in -y docker-bash-completion

systemctl enable --now docker

mkdir -p /etc/docker

cp /home/$TARGET_USERNAME/dotfiles/etc/docker/* /etc/docker/
echo "docker logs configured"

cp /home/$TARGET_USERNAME/dotfiles/scripts/docker/* /usr/local/bin/

if [ ! -f /usr/local/bin/k3s ]; then
    bash $SCRIPT_DIR/../../derivations/kube.sh
fi

cp -R /home/$TARGET_USERNAME/dotfiles/scripts/kube/* /usr/local/bin/
