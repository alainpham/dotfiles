#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
format=mkv

echo "ffmpeg -i $1 -vcodec copy -acodec copy ${filename}.${format}"

ffmpeg -i $1 -vcodec copy -acodec copy ${filename}.${format}
