#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

zypper in -y docker docker-compose skopeo skopeo-bash-completion docker-buildx docker-bash-completion

systemctl enable --now docker

if [ ! -f /usr/local/bin/k3s ]; then
    bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/kube.sh
fi

