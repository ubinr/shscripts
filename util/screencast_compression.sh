#!/bin/bash
printf '\033c'
#https://gist.github.com/shadyonline/314ba044b2ed4d93dcc226a878ea7648

#AAC_ENCODER=libfdk_aac
readonly AAC_ENCODER=aac

readonly AUDIO_PARAMS="-c:a $AAC_ENCODER -profile:a aac_low -b:a 128k"
readonly VIDEO_PARAMS="-pix_fmt yuv420p -c:v libx264 -profile:v high -preset slow -crf 18 -g 30 -bf 2"
readonly CONTAINER_PARAMS="-movflags faststart"

# You need to adjust the GOP length to fit your source video.
# 60 fps -> -g 30
# 23.976 (24000/1001) -> -g 24000/1001/2  (???) <- plz comment

let -i P720_MIN=612
let -i P480_MAX=611
let -i P480_MIN=420
let -i P360_MAX=419

echo " ..."
echo " --> ................................... file: $1"

eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $1)
declare V_WIDTH=${streams_stream_0_width}
declare V_HEIGHT=${streams_stream_0_height}
let -i V_2SCALE=-1

echo " ..."
echo -e "\t height:${V_HEIGHT}  width:${V_WIDTH}"

if (($V_HEIGHT >= $P720_MIN)); then
  V_2SCALE=720
elif (($V_HEIGHT <= $P480_MAX && $V_HEIGHT >= $P480_MIN)); then
  V_2SCALE=480
else
  V_2SCALE=360
fi

echo " ..."
echo " scaling to [ ${V_2SCALE}P ]"
echo " ..."
echo " creating new file -> $2"
echo " ..."

# -vf scale=-2:480
# -vf "crop=iw-10:ih,scale=854:480:0:0"
# -vf "scale=(iw*sar)*max(720/(iw*sar)\,480/ih):ih*max(720/(iw*sar)\,480/ih), crop=720:480"
#  -t 500
/usr/bin/ffmpeg -y -i "$1" $AUDIO_PARAMS $VIDEO_PARAMS -vf scale=-2:"${V_2SCALE}" $CONTAINER_PARAMS "$2" -nostdin

echo " ..."
echo -e " <-- ...................................  $2  completed!\n"
