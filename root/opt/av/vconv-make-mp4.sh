#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
format=mp4

echo "ffmpeg -i $1 -vcodec copy -acodec copy -movflags +faststart ${filename}.${format}"

ffmpeg -i $1 -vcodec copy -acodec copy -movflags +faststart ${filename}.${format}
