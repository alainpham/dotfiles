#!/bin/sh
echo starting X>~/.xinit.log

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -n "$XDG_RUNTIME_DIR" ] && \
    [ "$XDG_RUNTIME_DIR" = "/run/user/`id -u`" ] && \
    [ -S "$XDG_RUNTIME_DIR/bus" ]; then
  DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
  export DBUS_SESSION_BUS_ADDRESS
fi

if [ -x "/usr/bin/dbus-update-activation-environment" ]; then
  dbus-update-activation-environment --verbose --systemd \
    DBUS_SESSION_BUS_ADDRESS \
    DISPLAY \
    XAUTHORITY \
    XDG_CURRENT_DESKTOP \
    ${NULL+}
fi

if grep -qi hypervisor /proc/cpuinfo; then
    echo inside vm, launching spice-vdagent >>~/.xinit.log
    spice-vdagent
fi

if [ ! -f ~/.nonumlock ]; then
    numlockx
fi

dunst > ~/.dunst.log &
echo 1 | tee ~/.rebootdwm
export rebootdwm=$(cat ~/.rebootdwm)
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
export XCURSOR_SIZE=24
while true; do

    piddunst=$(pgrep dunst)
    if [ ! -z "$piddunst" ]; then
        kill -9 $piddunst
        echo dunst restarted>>~/.xinit.log
    fi
    dunst > ~/.dunst.log &

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

    if [ -f ~/.fehbg ]; then
        ~/.fehbg
        echo feh script exists, setting backround with it>>~/.xinit.log
    else
        sbg
        echo first boot, setting random>>~/.xinit.log
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
    
    # Log stderror to a file
    dwm 2> ~/.dwm.log
    # No error logging
    #dwm >/dev/null 2>&1
    rebootdwm=$(cat ~/.rebootdwm)
    if [ "$rebootdwm" != '1' ]; then
            break
    fi
done