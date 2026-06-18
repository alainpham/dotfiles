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
    qemu-img \
    libvirt-client \
    libvirt-daemon \
    virt-install \
    guestfs-tools \
    virt-manager \
    bridge-utils \
    libosinfo