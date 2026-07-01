#!/bin/bash
set -euo pipefail

zypper in -y ansible java-25-openjdk-devel maven nodejs-default npm-default go
zypper in -y apache2 php8 php8-cli apache2-mod_php8 php8-sqlite

