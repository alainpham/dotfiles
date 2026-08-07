#!/bin/bash
set -euo pipefail

pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    skopeo \
    docker-buildx

systemctl enable --now docker

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/kube.sh

systemctl enable firstboot-dockernet.service
systemctl enable firstboot-dockerbuildx.service
