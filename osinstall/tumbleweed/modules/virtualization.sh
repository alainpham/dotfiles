#!/bin/bash
set -euo pipefail

zypper in -y \
    libvirt-client \
    qemu-img \
    virt-install \
    virt-manager \
    libvirt-daemon \
    libosinfo

systemctl enable libvirtd.service