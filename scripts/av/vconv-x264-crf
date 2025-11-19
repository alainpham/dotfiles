#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
#1080p 4000k
#720p  2264k
crf=${2:-17}
ab=${3:-384}
format=${4:-mp4}

ffmpeg -y -i $1 \
    -preset fast \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -crf ${crf} \
    -c:a libfdk_aac \
    -b:a ${ab}k \
    -f ${format} \
    ${filename}-x264-crf${crf}-fdk_aac-ab${ab}k.${format}
