#!/bin/bash

asnddef &
mon &

thunar --daemon & 

if [ -f "$HOME/.fehbg" ]; then
    sleep 5 && ~/.fehbg &
else
    sleep 5 && sbg &
fi

if command -v sunshine >/dev/null 2>&1; then
    if [ -f "$HOME/.shunshineonboot" ]; then
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
    fi
fi
