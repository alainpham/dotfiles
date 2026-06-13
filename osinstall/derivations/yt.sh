#!/bin/bash
set -euo pipefail

wget -O /usr/local/bin/yt-dlp \
  https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp

chmod 755 /usr/local/bin/yt-dlp
