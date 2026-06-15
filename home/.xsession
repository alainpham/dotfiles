#!/bin/sh
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
