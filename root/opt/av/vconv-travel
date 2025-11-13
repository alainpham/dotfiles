#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"

encoder=${2}
quality=26

if [[ "$encoder" == "vaapi" ]]; then
    inputparam="
    -init_hw_device vaapi=hw:/dev/dri/renderD128 -filter_hw_device hw
    -vaapi_device /dev/dri/renderD128
    -hwaccel vaapi
    -hwaccel_output_format vaapi
    "
    video_codec="
    -vaapi_device /dev/dri/renderD128 
    -c:v h264_vaapi
    -vf format=nv12|vaapi,hwupload,scale_vaapi=w=1024:h=-2 
    -qp ${quality}
    "
elif [[ "$encoder" == "nvenc" ]]; then
    inputparam="-hwaccel cuda -hwaccel_output_format cuda"
    video_codec="-preset p1 -c:v h264_nvenc -vf scale_cuda=w=1024:h=-2 -rc:v vbr -cq:v ${quality} -b:v 0"
else
    inputparam=""
    video_codec="-preset fast -pix_fmt yuv420p -c:v libx264 -vf scale=1024:-2 -crf ${quality}"
fi

ffmpeg -y \
    $inputparam \
    -i "$1" \
    -f mp4 \
    -map 0:v:0 \
    -map 0:a:0 \
    -map 0:s:0? \
    $video_codec \
    -c:a copy \
    -c:s mov_text \
    -movflags +faststart \
    "${filename} - travel.mp4"


# with rencode audio
# ffmpeg -y \
#     $inputparam \
#     -i "$1" \
#     -f mp4 \
#     -map 0:v:0 \
#     -map 0:a:0 \
#     -map 0:s:0? \
#     $video_codec \
#     -c:a libfdk_aac \
#     -b:a 64k \
#     -ac 1 \
#     -c:s mov_text \
#     -movflags +faststart \
#     "${filename} - travel.mp4"