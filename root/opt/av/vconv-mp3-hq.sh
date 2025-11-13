#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
ab=${3:-320}
format=${4:-mp3}

echo "ffmpeg -i $1 -acodec mp3 -ab ${ab}k ${filename}-mp3-ab${ab}k.${format}"

ffmpeg -i "$1" -acodec mp3 -ab ${ab}k "${filename}-mp3-ab${ab}k.${format}"
