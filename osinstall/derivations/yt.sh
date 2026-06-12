#!/bin/bash
set -euo pipefail

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod 755 /usr/local/bin/yt-dlp
