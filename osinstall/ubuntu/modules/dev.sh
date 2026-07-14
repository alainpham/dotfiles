#!/bin/bash
set -euo pipefail

apt install -y ansible openjdk-25-jdk maven nodejs npm golang-go
apt install -y apache2 php php-cli libapache2-mod-php php-sqlite3

