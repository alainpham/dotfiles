#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
videostream=${2:-"0:v:0"}
audiostream=${3:-"0:a:0"}
format=${4:-mp4}

echo "ffmpeg -i $1 -map ${videostream} -map ${audiostream} -vcodec copy -acodec copy -movflags +faststart ${filename}.${format}"

ffmpeg -i $1 -map ${videostream} -map ${audiostream} -vcodec copy -acodec copy -movflags +faststart ${filename}.${format}
