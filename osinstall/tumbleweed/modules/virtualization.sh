#!/bin/bash
set -euo pipefail
# zypper in -y \
#     qemu-kvm \
#     qemu-tools \
#     libvirt \
#     libvirt-client \
#     libvirt-daemon-qemu \
#     virt-install \
#     virt-manager \
#     guestfs-tools \
#     bridge-utils \
#     libosinfo \
#     osinfo-db \
#     osinfo-db-tools \
#     mkisofs \
#     cdrkit-cdrtools-compat

zypper in -y \
    libvirt-client \
    qemu-img \
    virt-install \
    virt-manager \
    libvirt-daemon \
    libosinfo

systemctl enable libvirtd.service