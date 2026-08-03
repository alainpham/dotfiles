#!/bin/bash
set -euo pipefail

zypper in -y docker docker-compose skopeo skopeo-bash-completion docker-buildx docker-bash-completion

systemctl enable --now docker

bash /home/$TARGET_USERNAME/dotfiles/osinstall/derivations/kube.sh

systemctl enable firstboot-dockernet.service
systemctl enable firstboot-dockerbuildx.service
