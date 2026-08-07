#!/bin/bash
set -euo pipefail

pacman -S --needed --noconfirm \
    ansible \
    jdk25-openjdk \
    maven \
    nodejs \
    npm \
    go

pacman -S --needed --noconfirm \
    apache \
    php \
    php-apache \
    php-sqlite
