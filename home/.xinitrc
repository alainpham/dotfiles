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

#spice-vdagent

numlockx

dunst > ~/.dunst.log &
echo 1 | tee ~/.rebootdwm
export rebootdwm=$(cat ~/.rebootdwm)
export XCURSOR_SIZE=24
while true; do

    piddunst=$(pgrep dunst)
    if [ -z "$piddunst" ]; then
        dunst > ~/.dunst.log &
        echo dunst started>>~/.xinit.log
    else
        kill -9 $piddunst
        dunst >> ~/.dunst.log &
        echo dunst restarted>>~/.xinit.log
    fi

    piddwmblocks=$(pgrep dwmblocks)
    if [ -z "$piddwmblocks" ]; then
        dwmblocks &
        echo dwmblocks started>>~/.xinit.log
    else
        kill -9 $piddwmblocks
        dwmblocks &
        echo dwmblocks restarted>>~/.xinit.log
    fi
    if command -v libinput-gestures >/dev/null 2>&1; then
        pidgestures=$(pgrep -f libinput-gestures)
        if [ -z "$pidgestures" ]; then
            libinput-gestures &
            echo libinput-gestures started>>~/.xinit.log
        else
            kill -9 $pidgestures
            libinput-gestures &
            echo libinput-gestures restarted>>~/.xinit.log
        fi
    fi
    if [ -f ~/.fehbg ]; then
        ~/.fehbg
        echo feh script exists, setting backround with it>>~/.xinit.log
    else
        bgfile=$(ls /usr/share/backgrounds/ | shuf -n 1)
        feh --bg-fill /usr/share/backgrounds/${bgfile}
        echo first boot, setting random>>~/.xinit.log
    fi
    picom -b --config ~/.config/picom/picom.conf
    # Log stderror to a file
    dwm 2> ~/.dwm.log
    # No error logging
    #dwm >/dev/null 2>&1
    rebootdwm=$(cat ~/.rebootdwm)
    if [ "$rebootdwm" = '0' ]; then
            break
    fi
done