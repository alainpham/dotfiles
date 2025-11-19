#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
#1080p 3904k
#720p  2264k
bitrate=${2:-1104}
ab=${3:-96}
format=${4:-mp4}
width=${5:-1280}

x264yifigist=cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all

x264paramsrarbg=cabac=1:ref=4:deblock=-1,-1:analyse=0x3,0x113:me=umh:subme=9:psy-rd=1.00,0.15:merange=24:trellis=2:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=32:lookahead-threads=4:sliced-threads=0:sync-lookahead=2:nr=0:bluray-compat=0:constrained-intra=0:bframes=3:b-pyramid=2:b-adapt=2:b-bias=0:direct=auto:open-gop=0:weightp=2:keyint=250:min-keyint=25:scenecut=40:intra-refresh=0:rc-lookahead=50:qpmin=0:qpmax=69:qpstep=4:cplxblur=20.0:qblur0.5:vbv-maxrate=31250:vbv-bufsize=31250:aq-mode=3:partitions=all

x264minimal=cabac=1:ref=5:deblock=-1,-1:me=umh:subme=9:psy-rd=1.00,0.15:merange=24:trellis=2:chroma-qp-offset=0:bframes=5:b-adapt=2:direct=auto:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:aq-mode=3:partitions=all

x264params=$x264minimal


ffmpeg -y -i $1  -pix_fmt yuv420p -vf scale=${width}:-2 -c:v libx264 -b:v ${bitrate}k  -an -pass 1 -f ${format} -movflags +faststart /dev/null

ffmpeg -i $1  -pix_fmt yuv420p -vf scale=${width}:-2 -c:v libx264 -b:v ${bitrate}k -maxrate 3500K -bufsize 1000K -c:a libfdk_aac -b:a ${ab}k -pass 2 -f ${format} -movflags +faststart ${filename}-x264-vbr${bitrate}k-aac-ab${ab}k-720p.${format}
