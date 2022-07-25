#!/bin/bash
unset HISTFILE
# printf '\033c'

function timeFormat() {
  local str=""
  while IFS=':' read -ra NUMBERS; do
    for i in "${NUMBERS[@]}"; do
      [[ ! -z "$str" ]] && { str+="-"; }
      str+="${i}"
    done
  done <<<"$1"
  echo "$str"
  #return $str
}

readonly DATE_TIME=$(date +'%y%m%d_%H%M%S')
readonly CURRENT_DIR=${PWD##*/}
declare LOWERCASE_DIR=${CURRENT_DIR,,}
LOWERCASE_DIR=${LOWERCASE_DIR// /-}
readonly OUTPUT_DIR="${LOWERCASE_DIR}_${DATE_TIME}"

echo -e "\t starting \t __________________________________________________"
mkdir $OUTPUT_DIR
echo -e "\t created directory: \t ${OUTPUT_DIR}"

readonly FILES_DIR=(*.mp4)
#echo "${#FILES_DIR[@]}"
readonly FILE=${FILES_DIR[0]}
readonly CREATED_DATE=$(date -r "${FILE}" +'%y%m%d')
declare FILENAME="${FILE##*/}"
readonly EXTENSION="${FILENAME##*.}"
FILENAME="${FILENAME%.*}"

echo "  ..."
echo "  -->  .................................. input file: ${FILE}"
echo "  ..."
echo -e " \t EXT[ ${EXTENSION} ]   FILENAME[ ${FILENAME} ]"
#exit

# -to   End Time    extract seconds of the video starting from second to second
readonly argTo=$1
echo "  ..."
echo -e "\t End Time  $argTo"

# -ss   Input seeking   frame from the beginning of the movie
readonly argSs=$2
echo "  ..."
echo -e "\t Start Time  $argSs"

#string1="10:33:56"
#string2="10:36:10"
declare startTime=$(date -u -d "$argSs" +"%s")
declare endTime=$(date -u -d "$argTo" +"%s")
readonly timeDiff=$(date -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S.%3N")
readonly total=$(timeFormat $timeDiff)
startTime=$(timeFormat $argSs)
endTime=$(timeFormat $argTo)

readonly NEW_FILENAME="$(echo $LOWERCASE_DIR | sed -r 's/[_]+/-/g')_${CREATED_DATE}_${startTime}_${endTime}__${total}.${EXTENSION}"
#echo "./${OUTPUT_DIR}/${NEW_FILENAME}"
#exit
ffmpeg -y -ss "$argSs" -i "$FILE" -to "$timeDiff" -c copy -movflags faststart -avoid_negative_ts 1 -hide_banner "./${OUTPUT_DIR}/${NEW_FILENAME}" < /dev/null
#$FFMPEG_HOME/bin/ffmpeg -ss "$argSs" -i "$FILE" -to "$argTo" -c copy -avoid_negative_ts 1 "./${OUTPUT_DIR}/${NEW_FILENAME}"
#$FFMPEG_HOME/bin/ffmpeg -y -ss "$argSs" -to "$argTo" -i "$FILE" -c copy -copyts -avoid_negative_ts 1 "./${OUTPUT_DIR}/${NEW_FILENAME}" -nostdin
#$FFMPEG_HOME/bin/ffmpeg -y -i "$FILE" -ss "$argSs" -to "$argTo" "./${OUTPUT_DIR}/${NEW_FILENAME}" -nostdin
#$FFMPEG_HOME/bin/ffmpeg -y -i "$FILE" -ss "$argSs" -to "$argTo" -c:v copy -c:a copy "./${OUTPUT_DIR}/${NEW_FILENAME}" -nostdin
# $FFMPEG_HOME/bin/ffmpeg -y -i "$1" -ss "$3" -to "$2" -vcodec copy -acodec copy "./${OUTPUT_DIR}/${NEW_FILENAME}" -nostdin

echo "  ..."
echo -e "  <--  ......................  $NEW_FILENAME  completed!\n"
echo " ..."
echo -e "\t completed \t __________________________________________________"
# https://trac.ffmpeg.org/wiki/Seeking
# https://video.stackexchange.com/questions/27887/video-concatenation-puts-sound-out-of-sync
# https://superuser.com/questions/358155/how-can-i-avoid-a-few-seconds-of-blank-video-when-using-vcodec-copy
