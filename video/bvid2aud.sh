#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

readonly FILES_EXT='.mp4'

find . -maxdepth 1 -type f -name "*${FILES_EXT}" | while read flle; do

  echo ' file '$flle
  sleep 2

  declare FILE="${flle##*/}"
  declare FILENAME="${FILE%.*}"

  echo 'filename '$FILENAME
  sleep 2

  ffmpeg -y -i "$flle" -vn -acodec copy "${FILENAME}".aac -nostdin

done

# ffmpeg-normalize *.aac -t -5 -ext aac -c:a aac -b:a 160k -ar 44100
