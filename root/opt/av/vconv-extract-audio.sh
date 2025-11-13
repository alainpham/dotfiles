#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
stream=${2:-"0:a:0"}
format=${3:-mka}

echo "ffmpeg -i "$1" -map ${stream} -acodec copy ${filename}.${format}"

ffmpeg -i "$1" -map ${stream} -acodec copy "${filename}.${format}"
