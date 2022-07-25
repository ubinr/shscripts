#!/bin/bash
unset HISTFILE
printf '\033c'

readonly TIME_ARG=${1:-'00:00:00'}
readonly BRAND_ARG=${2:-''}
readonly THIS_DIR=${PWD##*/}
readonly FILES_DIR=(*.mp4)
readonly FILE=${FILES_DIR[0]}

eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height "$FILE")
readonly HEIGHT=${streams_stream_0_height}
readonly IMG_NAME=$HEIGHT$BRAND_ARG'.jpg'

echo 'img_name: '$IMG_NAME

ffmpeg -ss $TIME_ARG -i "$FILE" -vframes 1 -q:v 2 -qmin 1 -qmax 1 -f image2 $IMG_NAME
