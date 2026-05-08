#!/bin/bash

for i in {1..5}; do
    if pactl info >/dev/null 2>&1; then
        asnddef &
        break
    fi
    echo "Waiting for PulseAudio/PipeWire pulse server... ($i/5)"
    sleep 1
done

# Final check
if ! pactl info >/dev/null 2>&1; then
    echo "Pulse server not available after 5 retries"
    exit 1
fi

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

