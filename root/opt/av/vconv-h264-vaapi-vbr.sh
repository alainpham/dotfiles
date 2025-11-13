#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
#1080p 3904k
#720p  2264k
bitrate=${2:-3904}
ab=${3:-96}
format=${4:-mp4}

echo "ffmpeg -threads 6 -vaapi_device /dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -i $1 -vf 'format=nv12|vaapi,hwupload' -vcodec h264_vaapi -b:v ${bitrate}k -acodec aac -ab ${ab}k ${filename}-h264-vaapi-vbr${bitrate}k-aac-ab${ab}k.${format}"

ffmpeg -threads 6 -vaapi_device /dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -i $1 -vf 'format=nv12|vaapi,hwupload' -vcodec h264_vaapi -b:v ${bitrate}k -acodec libfdk_aac -ab ${ab}k ${filename}-h264-vaapi-vbr${bitrate}k-aac-ab${ab}k.${format}

