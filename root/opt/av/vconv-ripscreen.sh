#!/bin/bash
filename=$(date +"%Y-%m-%d_%H-%M-%S").mkv
screen=${1:-"0"}
quality=${2:-"tv"} # lq, std or hq, tv
# duration="03:03:31" is exactly 11011 seconds, 24000
duration=${3:-"03:03:31"}
preset=${4:-veryfast}
crf=${5:-23}
ab=${6:-160}

audiosrcs="
-f pulse -i from-desktop.monitor 
-f pulse -i from-caller.monitor  
-f pulse -i mic01-processed 
-f pulse -i mic02-processed
"

audioname="-metadata:s:a:0 title=mixed"

audiofilter="-filter_complex [1:a][2:a][3:a][4:a]amix=inputs=4:duration=longest[mixed]"

mapping="-map 0:v -map [mixed]"

if [ "$quality" = "lq" ]; then

crf=${5:-30}
ab=${6:-64}
fps=25

elif [ "$quality" = "std" ]; then

crf=${5:-23}
ab=${6:-160}
fps=25

elif [ "$quality" = "hq" ]; then

preset=${4:-fast}
crf=${5:-18}
ab=${6:-320}
fps=25
mapping="-map 0:v -map [mixed] -map 1:a -map 2:a -map 3:a -map 4:a"

audioname="
-metadata:s:a:0 title=mixed
-metadata:s:a:1 title=desktop
-metadata:s:a:2 title=caller
-metadata:s:a:3 title=mic01
-metadata:s:a:4 title=mic02
"

elif [ "$quality" = "tv" ]; then

preset=${4:-fast}
crf=${5:-23}
ab=${6:-160}
fps="60"
audiosrcs="-f pulse -i from-desktop.monitor "
audiofilter=""
mapping='-map "0:v" -map "1:a"'

fi


xcoord=$(($screen * 1920))

#gst-launch-1.0 audiotestsrc wave=sine freq=440 ! pulsesink device=from-desktop >/dev/null 2>&1 &
gst-launch-1.0 audiotestsrc wave=silence ! pulsesink device=from-desktop >/dev/null 2>&1 &
gst-launch-1.0 audiotestsrc wave=silence ! pulsesink device=from-caller >/dev/null 2>&1 &

sleep 3

command="
ffmpeg  
    -f x11grab 
        -video_size 1920x1080 
        -framerate $fps 
        -i ":0.0+$xcoord,0" 
    $audiosrcs
    -f matroska 
        $audiofilter 
        $mapping 
        $audioname
        -t ${duration} 
        -fps_mode cfr 
        -preset $preset 
        -pix_fmt yuv420p  
        -c:v libx264 
        -crf ${crf} 
        -c:a libfdk_aac 
        -b:a ${ab}k 
        $filename
"
echo $command
eval $command

killall gst-launch-1.0
