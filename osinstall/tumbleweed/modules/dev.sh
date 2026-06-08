#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

zypper in -y ansible java-25-openjdk-devel maven nodejs-default npm-default go
zypper in -y apache2 php8 php8-cli apache2-mod_php8 php8-sqlite

curl -fsSL https://opencode.ai/install | sudo -u $TARGET_USERNAME bash
curl -fsSL https://claude.ai/install.sh | sudo -u $TARGET_USERNAME bash