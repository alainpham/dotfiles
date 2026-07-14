#!/bin/bash
set -euo pipefail

apt install -y docker.io docker-compose-v2 skopeo docker-buildx

systemctl enable --now docker

if [ ! -f /usr/local/bin/k3s ]; then
    bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/kube.sh
fi

systemctl enable firstboot-dockernet.service
systemctl enable firstboot-dockerbuildx.service
