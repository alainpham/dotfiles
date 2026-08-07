#!/bin/bash
set -euo pipefail

pacman -S --needed --noconfirm \
    libvirt \
    qemu-img \
    virt-install \
    virt-manager \
    libosinfo

systemctl enable libvirtd.service
