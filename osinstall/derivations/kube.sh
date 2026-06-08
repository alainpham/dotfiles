#!/bin/bash
set -euo pipefail

curl -Lo /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s

chmod 755 /usr/local/bin/k3s

ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
ln -sf /usr/local/bin/k3s /usr/local/bin/crictl
ln -sf /usr/local/bin/k3s /usr/local/bin/ctr

curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE="true" INSTALL_K3S_SKIP_START="true" INSTALL_K3S_VERSION="${K3S_VERSION}" K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server --disable=servicelb,traefik --bind-address 172.17.0.1 --node-ip 172.17.0.1 --advertise-address 172.17.0.1" sh -

curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 755 /tmp/get_helm.sh
/tmp/get_helm.sh

kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
helm completion bash | tee /etc/bash_completion.d/helm > /dev/null

curl -fsSL -o /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
tar -xzvf /tmp/k9s.tar.gz  -C /usr/local/bin/ k9s
rm /tmp/k9s.tar.gz
chown root:root /usr/local/bin/k9s