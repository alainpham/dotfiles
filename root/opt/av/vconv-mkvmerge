#!/bin/bash

if [ $# -lt 3 ] || [ $# -gt 5 ]; then
  echo "Usage: $0 <input_video> <input_audio> <language_code> [audio_delay_ms] [set_default]"
  echo "  audio_delay_ms: optional, default=0 (milliseconds)"
  echo "  set_default: optional, default='yes' ('yes' or 'no')"
  exit 1
fi

INPUT1="$1"
INPUT2="$2"
LANG_CODE="$3"
AUDIO_DELAY_MS="${4:-0}"      # default to 0 if not given
SET_DEFAULT="${5:-y}"       # default to yes if not given

# Generate output filename (always mkv)
BASENAME="${INPUT1%.*}"
OUTPUT="${BASENAME}-merged.mkv"

# Count audio streams in input1
AUDIO_COUNT=$(ffprobe -v error -select_streams a -show_entries stream=index \
             -of csv=p=0 "$INPUT1" | wc -l)

# Start ffmpeg command
CMD="ffmpeg -i \"$INPUT1\""

# Add input2 with delay if not zero
if [ "$AUDIO_DELAY_MS" -ne 0 ]; then
  AUDIO_DELAY_SEC=$(awk "BEGIN {printf \"%.3f\", $AUDIO_DELAY_MS / 1000}")
  CMD+=" -itsoffset $AUDIO_DELAY_SEC -i \"$INPUT2\""
else
  CMD+=" -i \"$INPUT2\""
fi

CMD+=" -map 0 -map 1:a:0 -avoid_negative_ts 1 -c copy"

# Handle default disposition if requested
if [ "$SET_DEFAULT" == "y" ]; then
  for ((i=0; i<$AUDIO_COUNT; i++)); do
    CMD+=" -disposition:a:$i 0"
  done
  CMD+=" -disposition:a:$AUDIO_COUNT default"
fi

# Set language tag on added audio stream
CMD+=" -metadata:s:a:$AUDIO_COUNT language=$LANG_CODE"

# Output file
# CMD+=" -movflags +faststart \"$OUTPUT\""
CMD+=" \"$OUTPUT\""
# Show and run
echo "Running command:"
echo "$CMD"
eval $CMD

