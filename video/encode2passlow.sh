#!/bin/bash -i
unset HISTFILE
printf '\033c'

# CRF=26
# CRF=25
# CRF=23
LIMIT_FRAMERATE=30000/1001
# LIMIT_FRAMERATE=24000/1001

readonly THIS_DIR=${PWD##*/}
readonly FILES_DIR=(*.mp4)
readonly FILE=${FILES_DIR[0]}
typeset -l LOWC_DIR
LOWC_DIR=${THIS_DIR// /_}
readonly WORKIN_DIR=$LOWC_DIR'_'$(date +'%y%m%d-%H%M%S')
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height "$FILE")
readonly HEIGHT=${streams_stream_0_height}

if (($HEIGHT == '1080')); then
  # LIMIT_FRAMERATE=30000/1001
  VBITRATE=2000
  # VBITRATE=3250
  # VBITRATE=3500

elif (($HEIGHT == '720')); then
  # LIMIT_FRAMERATE=30000/1001
  VBITRATE=1000

elif (($HEIGHT == '480')); then
  VBITRATE=500

elif (($HEIGHT == '360')); then
  VBITRATE=300
  LIMIT_FRAMERATE=24000/1001

elif (($HEIGHT == '240')); then
  VBITRATE=250
  LIMIT_FRAMERATE=24000/1001
fi

declare FILENAME="${FILE##*/}"
declare EXTENSION="${FILENAME##*.}"
FILENAME="${FILENAME%.*}"
declare NEW_FILENAME="${FILENAME}[${HEIGHT}p].${EXTENSION}"

mkdir $WORKIN_DIR

# ffmpeg -y -i "$FILE" -vf scale=-2:480 -pix_fmt yuv420p -c:v libx264 -preset slow -crf $CRF -r $LIMIT_FRAMERATE -pass 1 -c:a aac -f mp4 /dev/null && \
# ffmpeg -i "$FILE" -vf scale=-2:480 -pix_fmt yuv420p -c:v libx264 -preset slow -r $LIMIT_FRAMERATE -b:v "${VBITRATE}k" -pass 2 -c:a aac -f mp4 -movflags faststart -avoid_negative_ts 1 -hide_banner -y "./${WORKIN_DIR}/${NEW_FILENAME}"

ffmpeg -y -i "$FILE" -pix_fmt yuv420p -c:v libx264 -preset slow -b:v "${VBITRATE}k" -r $LIMIT_FRAMERATE -maxrate $LIMIT_FRAMERATE -minrate $LIMIT_FRAMERATE -bufsize "${VBITRATE}k" -pass 1 -c:a copy -f mp4 /dev/null && \
ffmpeg -i "$FILE" -pix_fmt yuv420p -c:v libx264 -preset slow -b:v "${VBITRATE}k" -r $LIMIT_FRAMERATE -maxrate $LIMIT_FRAMERATE -minrate $LIMIT_FRAMERATE -bufsize "${VBITRATE}k" -pass 2 -c:a copy -f mp4 -movflags faststart -avoid_negative_ts 1 -hide_banner "./${WORKIN_DIR}/${NEW_FILENAME}" < /dev/null

# VBITRATE=3500
# VBITRATE=3100
# VBITRATE=2500
# VBITRATE=1000
# VBITRATE=850
# VBITRATE=700
# VBITRATE=500
# 720p 30fps Bitrate: 2500 to 4000 kbps Resolution: 1280 x 720


# https://www.miracletutorials.com/bitrate-hls-video/
# https://www.virag.si/2012/06/h.264-web-video-encoding-tutorial-with-ffmpeg/
# https://thewebaround.com/gaming/the-best-streaming-settings-for-obs-2021/
# https://www.lighterra.com/papers/videoencodingh264/
# https://blog.mobcrush.com/how-to-choose-the-right-bitrate-for-your-stream-9864ce322a9b
# https://streamlabs.com/content-hub/post/best-bitrate-settings-for-live-streaming
