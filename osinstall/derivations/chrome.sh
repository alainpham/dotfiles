#!/bin/bash
set -euo pipefail

mkdir -p /opt/rpms/
rpm --import https://dl.google.com/linux/linux_signing_key.pub
wget -O /opt/rpms/google-chrome-stable_current_x86_64.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
zypper install -y /opt/rpms/google-chrome-stable_current_x86_64.rpm

