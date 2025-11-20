#!/bin/bash
asnddef &
mon &

if [ -f "$HOME/.fehbg" ]; then
    sleep 5 && ~/.fehbg &
else
    sleep 5 && sbg &
fi



if command -v sunshine >/dev/null 2>&1; then
    pkill sunshine ; sunshine &
fi

if command -v gshorts >/dev/null 2>&1; then
    pkill gshorts ; gshorts &
fi

if command -v slack >/dev/null 2>&1; then
    slack &
    echo slack started
fi