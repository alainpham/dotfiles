#!/bin/bash
set -euo pipefail

if [ "$(k3s --version 2>/dev/null | awk 'NR==1{print $3}')" != "${K3S_VERSION}" ]; then
    curl -Lo /tmp/k3s https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s
    mv /tmp/k3s /usr/local/bin/k3s

    chmod 755 /usr/local/bin/k3s

    curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_SELINUX_RPM="true" INSTALL_K3S_SKIP_ENABLE="true" INSTALL_K3S_SKIP_START="true" INSTALL_K3S_VERSION="${K3S_VERSION}" K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server --disable=servicelb,traefik --bind-address 172.17.0.1 --node-ip 172.17.0.1 --advertise-address 172.17.0.1" sh -
else
    echo "k3s ${K3S_VERSION} already installed, skipping"
fi

ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
ln -sf /usr/local/bin/k3s /usr/local/bin/crictl
ln -sf /usr/local/bin/k3s /usr/local/bin/ctr

curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 755 /tmp/get_helm.sh
/tmp/get_helm.sh

BASH_COMPLETION_DIR=/usr/share/bash-completion/completions
mkdir -p "$BASH_COMPLETION_DIR"
kubectl completion bash | tee "$BASH_COMPLETION_DIR/kubectl" > /dev/null
helm completion bash | tee "$BASH_COMPLETION_DIR/helm" > /dev/null

if [ "$(k9s version -s 2>/dev/null | awk '/^Version/{print $2}')" != "${K9S_VERSION}" ]; then
    curl -fsSL -o /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
    tar -xzvf /tmp/k9s.tar.gz  -C /usr/local/bin/ k9s
    rm /tmp/k9s.tar.gz
    chown root:root /usr/local/bin/k9s
else
    echo "k9s ${K9S_VERSION} already installed, skipping"
fi
