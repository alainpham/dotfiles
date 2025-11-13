#!/bin/bash

if [ $# -lt 2 ]; then
  exit 1
fi

AUDIOFILE="$1"
AUDIO_DELAY_MS="${2:-0}"  

BASENAME="${AUDIOFILE%.*}"
EXT="${AUDIOFILE##*.}"
OUTPUT="${BASENAME}-synced.$EXT"

# Start ffmpeg command

# Add input2 with delay if not zero
AUDIO_DELAY_SEC=$(awk "BEGIN {printf \"%.3f\", $AUDIO_DELAY_MS / 1000}")
CMD="ffmpeg -itsoffset $AUDIO_DELAY_SEC -i \"$AUDIOFILE\" -avoid_negative_ts 1 -c copy \"$OUTPUT\""

echo "Running command:"
echo "$CMD"
eval $CMD

