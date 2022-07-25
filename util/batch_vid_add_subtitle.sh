#!/bin/bash
unset HISTFILE
printf '\033c'

readonly EXT='.mp4'

find . -maxdepth 1 -type f -name "*${EXT}" | while read FILE; do
  declare FILENAME="${FILE##*/}"
  FILENAME="${FILENAME%.*}"
  echo ""
  echo " adding.. " ${FILENAME}[es].srt
  #ffmpeg -i "$FILE" -f srt -i "${FILENAME}[es].srt" -c:v copy -c:a copy -c:s mov_text "${FILENAME}[es].mp4"
  #ffmpeg -i "$FILE" -i "${FILENAME}[es].srt" -c copy \
  #-map 0 -c:s mov_text -map_metadata 0 \
  #"${FILENAME}_.mp4"
  #-metadata:s:s:3 language=spa -metadata:s:s:3 handler="Español" -id3v2_version 3 -write_id3v1 1

  ffmpeg -y -i "$FILE" -i "${FILENAME}.srt" -i "${FILENAME}[es].srt" -map 0 -map 1 -map 2 -c copy -c:s mov_text -c:s mov_text \
  -metadata:s:s:0 language=eng -disposition:s:0 +default+forced -metadata:s:s:1 language=spa \
  -id3v2_version 3 -write_id3v1 1 "${FILENAME}_.mp4" -nostdin
done
