#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
#extreme visually lossess at qp=14
#for normal visual lossless use qp=17 or 18
qp=${2:-17}
ab=${3:-384}
format=${4:-mp4}

echo "ffmpeg -threads 6 -vaapi_device /dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -i $1 -vf 'format=nv12|vaapi,hwupload' -vcodec h264_vaapi -qp ${qp} -acodec aac -ab ${ab}k ${filename}-h264-vaapi-qp${qp}-aac-ab${ab}k.${format}"

ffmpeg \
    -vaapi_device /dev/dri/renderD128 \
    -hwaccel vaapi \
    -hwaccel_output_format vaapi \
    -i $1 -vf 'format=nv12|vaapi,hwupload' \
    -vcodec h264_vaapi \
    -qp ${qp} \
    -acodec libfdk_aac \
    -ab ${ab}k \
    ${filename}-h264-vaapi-qp${qp}-fdk_aac-ab${ab}k.${format}
