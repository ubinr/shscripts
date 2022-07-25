#!/bin/bash
unset HISTFILE
printf '\033c'
#https://gist.github.com/shadyonline/314ba044b2ed4d93dcc226a878ea7648

# AAC_ENCODER=libfdk_aac
# AAC_ENCODER=aac

AUDIO_PARAMS="-c:a copy"
# AUDIO_PARAMS="-c:a $AAC_ENCODER -profile:a aac_low -b:a 128k"
VIDEO_PARAMS="-pix_fmt yuv420p -vf scale=-1:720 -c:v libx264 -profile:v high -preset slow -crf 23 -r 24000/1001 -bf 2"
# VIDEO_PARAMS="-pix_fmt yuv420p -vf scale=-1:720 -c:v libx264 -profile:v high -preset slow -crf 22 -r 3000/100 -bf 2"
CONTAINER_PARAMS="-movflags faststart"

# You need to adjust the GOP length to fit your source video.
# 60 fps -> -g 30
# 23.976 (24000/1001) -> -g 24000/1001/2  (???) <- plz comment

ffmpeg -y -async 1 -i "$1" $AUDIO_PARAMS $VIDEO_PARAMS $CONTAINER_PARAMS "$2" -nostdin
