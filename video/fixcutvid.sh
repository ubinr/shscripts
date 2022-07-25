#!/bin/bash -i
unset HISTFILE
printf '\033c'
shopt -s nullglob

readonly PARTVID=$(find . -maxdepth 1 -type f -name "*.mp4.part" | head -n 1)
FILE=

if [[ -f "$PARTVID" && -s "$PARTVID" ]]; then
  declare FILENAME="${PARTVID##*/}"
  declare EXTENSION="${FILENAME##*.}"
  declare FILENAME="${FILENAME%.*}"
  FILE="${FILENAME}"
  mv "$PARTVID" "$FILE"
else

  declare EXCL_VID=${1:-'sample*.mp4'}
  FILE=$(find . -maxdepth 1 -type f -name "*.mp4" | grep -v "$EXCL_VID" | head -n 1)
fi

# readonly FILE=$(ls *.mp4 | ls -I "$EXCL_VID" | head -n 1)
echo "  > >> >>  input: ${FILE}"

eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=duration "$FILE")
readonly DUT=${streams_stream_0_duration}
readonly endd=$(time_fmtopr $DUT '+' 1)

echo "duration [ $endd ] $DUT"
echo 'cut___'$endd'___0'
cutsvid "$FILE" $endd 0
