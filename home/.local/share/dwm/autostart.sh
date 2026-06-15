#!/bin/bash

for i in {1..6}; do
    if pactl info >/dev/null 2>&1; then
        asnddef &
        break
    fi
    echo "Waiting for PulseAudio/PipeWire pulse server... ($i/5)">>~/.xinit.log
    sleep 1
done

# Final check
if ! pactl info >/dev/null 2>&1; then
    echo "Pulse server not available after 5 retries"
    exit 1
fi

if [ ! -f ~/.nonumlock ]; then
    numlockx
fi


if [ -f ~/.xdpi ]; then 
    export XDPI=$(cat ~/.xdpi)
else
    export XDPI=96
fi

xrandr --dpi $XDPI

export WINIT_X11_SCALE_FACTOR=$(awk -v xdpi="$XDPI" 'BEGIN { printf "%.2f\n", xdpi/96 }')
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE=24
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources && echo ".Xresources loaded">>~/.xinit.log

mon &

thunar --daemon & 


if grep -qi hypervisor /proc/cpuinfo; then
    echo inside vm, launching spice-vdagent >>~/.xinit.log
    spice-vdagent
fi

if [ -f "$HOME/.fehbg" ]; then
    sleep 5 && ~/.fehbg &
else
    sleep 5 && sbg &
fi

if [ ! -f ~/.gtkrc-2.0 ]; then 
theme
fi

piddwmblocks=$(pgrep dwmblocks)
if [ ! -z "$piddwmblocks" ]; then
    kill -9 $piddwmblocks
    echo dwmblocks restarted>>~/.xinit.log
fi
dwmblocks &


if command -v libinput-gestures >/dev/null 2>&1; then
    pidgestures=$(pgrep -f libinput-gestures)
    if [ ! -z "$pidgestures" ]; then
        kill -9 $pidgestures
        echo libinput-gestures restarted>>~/.xinit.log
    fi
    libinput-gestures &
fi


if command -v sunshine >/dev/null 2>&1; then
    if [ -f "$HOME/.sunshineonboot" ]; then
        pkill sunshine ; sunshine &
    fi
fi

if command -v gshorts >/dev/null 2>&1; then
    pkill gshorts ; gshorts &
fi

if command -v slack >/dev/null 2>&1; then
    if ! pgrep -x "slack" > /dev/null; then
        slack &
        echo slack started
    else
        echo slack already started
    fi
fi

if flatpak list | grep -q slack; then
    if ! pgrep -x "slack" > /dev/null; then
        flatpak run com.slack.Slack &
        echo flatpak slack started
    else
        echo flatpak slack already started
    fi
fi

if [ ! -f ~/.nopicom ]; then
    pidpicom=$(pgrep picom)
    if [ ! -z "$pidpicom" ]; then
        kill -9 $pidpicom
        while pgrep -x picom > /dev/null; do
            sleep 1
        done
    fi

    picom -b --config ~/.config/picom/picom.conf
fi
