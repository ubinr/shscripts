#!/bin/bash
unset HISTFILE
printf '\033c'

readonly OK_VID=${1:-'sample*.*'}
SAMPLE=($OK_VID)
SAMPLE=$(echo $SAMPLE)
readonly THIS_DIR=${PWD##*/}
# readonly FILES_DIR=(!(sample).mp4)
# readonly FILES_DIR=("$(ls *.mp4 | grep -wv '^'$SAMPLE)")
# readonly FILES_DIR=(*.mp4)
readonly BROKEN_VID=$(find . -maxdepth 1 -type f -name "*.mp4" | grep -v "$OK_VID" | head -n 1)
# readonly BROKEN_VID=$(ls *.mp4 | ls -I "$OK_VID" | head -n 1)
# readonly BROKEN_VID=${FILES_DIR[0]}

echo 'working_vi: '$SAMPLE

untrunc "$SAMPLE" "$BROKEN_VID"
